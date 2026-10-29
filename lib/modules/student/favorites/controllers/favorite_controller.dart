import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/hostel_filter.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/student_home_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../../hostel_detail/widgets/hostel_filter_sheet.dart';
import '../../widegts/hostel_listing.dart';

/// "Kab save kiya" ke chips
enum FavPeriod {
  all,
  day,
  week,
  month;

  String get label {
    switch (this) {
      case FavPeriod.all:
        return 'All';
      case FavPeriod.day:
        return '1 Day';
      case FavPeriod.week:
        return '1 Week';
      case FavPeriod.month:
        return '1 Month';
    }
  }

  Duration? get window {
    switch (this) {
      case FavPeriod.all:
        return null;
      case FavPeriod.day:
        return const Duration(days: 1);
      case FavPeriod.week:
        return const Duration(days: 7);
      case FavPeriod.month:
        return const Duration(days: 30);
    }
  }
}

class FavoritesController extends GetxController {
  final StudentHomeRepository _repo;
  final AuthRepository _auth;
  FavoritesController(this._repo, this._auth);

  /// Sab active hostels (Details ke "Related" ke liye bhi)
  final allListings = <HostelListing>[].obs;

  /// Student ke favorites: hostelId -> kab save kiya (null = purana, tareekh nahi)
  final entries = <String, DateTime?>{}.obs;

  final period = FavPeriod.all.obs;
  final filter = Rx<HostelFilter>(const HostelFilter());
  final query = ''.obs;
  final showSearch = false.obs;

  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<Map<String, DateTime?>>? _sub;

  String get _uid => _auth.currentUid ?? '';

  @override
  void onReady() {
    super.onReady();
    _sub = _repo
        .watchFavoriteEntries(_uid)
        .listen(entries.assignAll, onError: (_) {});
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await NetworkManager.instance.ensureConnected();
      allListings.assignAll(await _repo.fetchListings());
    } catch (e, s) {
      final msg = ExceptionHandler.message(e, s);
      if (allListings.isNotEmpty) {
        AppSnackbar.error(msg);
      } else {
        errorMessage.value = msg;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------------
  /// Sirf favorite hostels (filter panel ke options inhi se bante hain)
  List<HostelListing> get _saved =>
      allListings.where((l) => entries.containsKey(l.hostel.id)).toList();

  List<String> get cities {
    final map = <String, String>{};
    for (final l in _saved) {
      final c = l.hostel.city.trim();
      if (c.isNotEmpty) map.putIfAbsent(c.toLowerCase(), () => c);
    }
    return map.values.toList()..sort();
  }

  List<String> get amenityOptions {
    final map = <String, String>{};
    for (final l in _saved) {
      for (final a in l.hostel.amenities) {
        final t = a.trim();
        if (t.isNotEmpty) map.putIfAbsent(t.toLowerCase(), () => t);
      }
    }
    return map.values.toList()..sort();
  }

  /// Chip + search + filter laga kar, sab se naya save kiya hua pehle
  List<HostelListing> get visible {
    final now = DateTime.now();
    final window = period.value.window;
    final q = query.value;
    final f = filter.value;

    final list = allListings.where((l) {
      final id = l.hostel.id;
      if (!entries.containsKey(id)) return false;

      if (window != null) {
        final t = entries[id];
        if (t == null || now.difference(t) > window) return false;
      }

      if (q.isNotEmpty) {
        final h = l.hostel;
        final hit = h.name.toLowerCase().contains(q) ||
            h.city.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q);
        if (!hit) return false;
      }
      return f.matches(l);
    }).toList();

    final epoch = DateTime(1970);
    list.sort((a, b) => (entries[b.hostel.id] ?? epoch)
        .compareTo(entries[a.hostel.id] ?? epoch));
    return list;
  }

  void setPeriod(FavPeriod p) => period.value = p;

  void setQuery(String q) => query.value = q.trim().toLowerCase();

  void toggleSearch() {
    showSearch.value = !showSearch.value;
    if (!showSearch.value) query.value = '';
  }

  void openFilters() {
    Get.bottomSheet(
      HostelFilterSheet(
        initial: filter.value,
        cities: cities,
        amenityOptions: amenityOptions,
        onApply: (f) => filter.value = f,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void resetFilters() {
    filter.value = const HostelFilter();
    period.value = FavPeriod.all;
  }

  Future<void> removeFavorite(String hostelId) async {
    final backup = entries[hostelId];
    entries.remove(hostelId);

    try {
      await _repo.setFavorite(_uid, hostelId, false);
      AppSnackbar.info('Removed from favorites');
    } catch (e, s) {
      entries[hostelId] = backup;
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  void viewDetails(HostelListing listing) {
    Get.toNamed(
      AppRoutes.hostelDetails,
      arguments: HostelDetailsArgs(listing, allListings.toList()),
    );
  }

  void browseHostels() => Get.offAllNamed(AppRoutes.studentHome);

  void openNotifications() => AppSnackbar.info('No new notifications.');

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}