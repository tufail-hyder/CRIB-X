import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/student_home_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../../widegts/hostel_listing.dart';

enum HomeTab {
  featured,
  quick,
  recent;

  String get label {
    switch (this) {
      case HomeTab.featured:
        return 'Featured Hostel';
      case HomeTab.quick:
        return 'Quick Access';
      case HomeTab.recent:
        return 'Recent Hostels';
    }
  }
}

class StudentDashboardController extends GetxController {
  final StudentHomeRepository _repo;
  final AuthRepository _auth;
  StudentDashboardController(this._repo, this._auth);

  final listings = <HostelListing>[].obs;
  final myStay = Rxn<StudentModel>();
  final favorites = <String>{}.obs;

  final tab = HomeTab.featured.obs;
  final query = ''.obs;
  final showSearch = false.obs;
  final showBanner = true.obs;

  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<Set<String>>? _favSub;

  String get _uid => _auth.currentUid ?? '';

  @override
  void onReady() {
    super.onReady();
    _favSub = _repo
        .watchFavorites(_uid)
        .listen(favorites.assignAll, onError: (_) {});
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await NetworkManager.instance.ensureConnected();

      final hostels = await _repo.fetchHostels();
      final beds = await _repo.fetchAvailableBeds(); // null = pata nahi
      final stay = await _repo.fetchMyStay(_uid);

      listings.assignAll(
        hostels.map((h) => HostelListing(h, beds == null ? null : (beds[h.id] ?? 0))),
      );
      myStay.value = stay;
    } catch (e, s) {
      final msg = ExceptionHandler.message(e, s);
      if (listings.isNotEmpty) {
        AppSnackbar.error(msg);
      } else {
        errorMessage.value = msg;
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<HostelListing> get visible {
    final q = query.value;
    var list = listings.where((l) {
      if (q.isEmpty) return true;
      final h = l.hostel;
      return h.name.toLowerCase().contains(q) ||
          h.city.toLowerCase().contains(q) ||
          h.address.toLowerCase().contains(q);
    }).toList();

    switch (tab.value) {
      case HomeTab.featured:
        int score(HostelModel h) => h.images.length * 2 + h.amenities.length;
        list.sort((a, b) => score(b.hostel).compareTo(score(a.hostel)));
        break;

      case HomeTab.quick:
        list = list.where((l) => !l.isFull).toList();
        double price(HostelModel h) =>
            h.monthlyPrice == 0 ? double.infinity : h.monthlyPrice;
        list.sort((a, b) => price(a.hostel).compareTo(price(b.hostel)));
        break;

      case HomeTab.recent:
        final epoch = DateTime(1970);
        list.sort((a, b) => (b.hostel.createdAt ?? epoch)
            .compareTo(a.hostel.createdAt ?? epoch));
        break;
    }
    return list;
  }

  void setTab(HomeTab t) => tab.value = t;

  void setQuery(String q) => query.value = q.trim().toLowerCase();

  void toggleSearch() {
    showSearch.value = !showSearch.value;
    if (!showSearch.value) query.value = '';
  }

  void dismissBanner() => showBanner.value = false;

  Future<void> toggleFavorite(String hostelId) async {
    final add = !favorites.contains(hostelId);
    add ? favorites.add(hostelId) : favorites.remove(hostelId);

    try {
      await _repo.setFavorite(_uid, hostelId, add);
    } catch (e, s) {
      add ? favorites.remove(hostelId) : favorites.add(hostelId);
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  void viewDetails(HostelModel hostel) =>
      AppSnackbar.info('Hostel details screen is coming next.');

  void openNotifications() => AppSnackbar.info('No new notifications.');

  static const _none = '—';

  String get roomBedText {
    final s = myStay.value;
    return s == null ? _none : '${s.roomNumber} · ${s.bed}';
  }

  String get nextDueText {
    final s = myStay.value;
    if (s == null) return _none;
    final now = DateTime.now();
    final due = s.paymentStatus == PaymentStatus.paid
        ? DateTime(now.year, now.month + 1, StudentModel.dueDay)
        : DateTime(now.year, now.month, StudentModel.dueDay);
    return '${monthShort(due)} ${due.day}';
  }

  String get rentStatusText {
    final s = myStay.value;
    return s == null ? _none : s.paymentStatus.label;
  }

  String get stayDurationText {
    final s = myStay.value;
    if (s == null) return _none;
    final days = DateTime.now().difference(s.checkInDate).inDays;
    final n = days < 0 ? 0 : days;
    return '$n ${n == 1 ? 'Day' : 'Days'}';
  }

  @override
  void onClose() {
    _favSub?.cancel();
    super.onClose();
  }
}