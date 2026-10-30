import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/student_home_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../../profile_settings/widgets/student_dialog_widget.dart';
import '../../widegts/hostel_listing.dart';
import '../widgets/booking_request_sheet.dart';

class HostelDetailsController extends GetxController {
  final StudentHomeRepository _repo;
  final BookingRepository _bookings;
  final AuthRepository _auth;
  final HostelListing listing;
  final List<HostelListing> all;

  HostelDetailsController(
      this._repo, this._bookings, this._auth, this.listing, this.all);

  final rooms = <RoomModel>[].obs;
  final favorites = <String>{}.obs;
  final selectedImage = 0.obs;
  final isLoadingRooms = true.obs;
  final isRequesting = false.obs;
  bool _requestSent = false;

  StreamSubscription<Set<String>>? _favSub;

  HostelModel get hostel => listing.hostel;
  String get _uid => _auth.currentUid ?? '';

  @override
  void onInit() {
    super.onInit();
    _favSub = _repo
        .watchFavorites(_uid)
        .listen(favorites.assignAll, onError: (_) {});
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      rooms.assignAll(await _repo.fetchRooms(hostel.id));
    } catch (_) {
    } finally {
      isLoadingRooms.value = false;
    }
  }

  List<RoomModel> get freeRooms =>
      rooms.where((r) => r.availableBeds > 0).toList();

  int get availableBeds =>
      rooms.isEmpty ? (listing.availableBeds ?? 0) : freeRooms.fold(0, (s, r) => s + r.availableBeds);

  bool hasRoomType(int seater) => rooms.any((r) => r.seater == seater);

  double? get displayPrice {
    final prices =
    freeRooms.map((r) => r.monthlyPrice).where((p) => p > 0).toList()..sort();

    if (hostel.monthlyPrice > 0) return hostel.monthlyPrice;
    return prices.isEmpty ? listing.minRoomPrice : prices.first;
  }

  List<HostelListing> get related {
    final city = hostel.city.trim().toLowerCase();
    final others = all.where((l) => l.hostel.id != hostel.id).toList();
    int score(HostelListing l) =>
        (l.hostel.city.trim().toLowerCase() == city ? 1000 : 0) +
            l.hostel.images.length * 2 +
            l.hostel.amenities.length;
    others.sort((a, b) => score(b).compareTo(score(a)));
    return others.take(4).toList();
  }

  void openRelated(HostelListing l) {
    Get.toNamed(
      AppRoutes.hostelDetails,
      arguments: HostelDetailsArgs(l, all),
      preventDuplicates: false,
    );
  }

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

  void openNotifications() => AppSnackbar.info('No new notifications.');

  // ------------------------------------------------------------------
  // Book Now
  Future<void> startBooking() async {
    if (isLoadingRooms.value) return;
    if (freeRooms.isEmpty) {
      AppSnackbar.warning('No free beds in this hostel right now.');
      return;
    }

    try {
      isRequesting.value = true;
      await NetworkManager.instance.ensureConnected();

      if (await _bookings.hasPendingRequest(hostel.id, _uid)) {
        AppSnackbar.info('You already have a pending request for this hostel.');
        return;
      }
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
      return;
    } finally {
      isRequesting.value = false;
    }

    _requestSent = false;
    await Get.bottomSheet(
      BookingRequestSheet(
        hostelName: hostel.name,
        rooms: freeRooms,
        onSubmit: _submitBooking,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );

    if (_requestSent) {
      _requestSent = false;
      await StudentDialogs.success(
        message: 'Booking request sent to ${hostel.name}',
      );
    }
  }

  Future<bool> _submitBooking(BookingDraft d) async {
    try {
      await NetworkManager.instance.ensureConnected();

      final user = await _auth.getCurrentUser();
      if (user == null) {
        AppSnackbar.error('Please log in again.');
        return false;
      }

      await _bookings.createBooking(BookingModel(
        id: '',
        hostelId: hostel.id,
        studentName: user.name,
        phone: user.phone,
        userId: user.uid,
        roomId: d.room.id,
        roomNumber: d.room.roomNumber,
        seater: d.room.seater,
        bed: d.bed,
        checkInDate: d.checkIn,
        durationMonths: d.months,
      ));

      _requestSent = true;
      return true;
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
      return false;
    }
  }

  @override
  void onClose() {
    _favSub?.cancel();
    super.onClose();
  }
}