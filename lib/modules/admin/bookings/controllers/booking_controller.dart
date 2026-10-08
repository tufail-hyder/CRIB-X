import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../widgets/booking_action_menu.dart';
import '../widgets/booking_details_dialog.dart';

class BookingsController extends GetxController {
  final BookingRepository _repo;
  final AuthRepository _auth;
  BookingsController(this._repo, this._auth);

  static const seaterOptions = [1, 2, 3, 4, 5, 6];

  final bookings = <BookingModel>[].obs;

  final statusFilter = Rxn<BookingStatus>();
  final seaterFilter = RxnInt();
  final dateFilter = Rxn<DateTime>();

  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<BookingModel>>? _sub;

  @override
  void onReady() {
    super.onReady();
    listen();
  }

  void listen() {
    isLoading.value = true;
    errorMessage.value = null;
    _sub?.cancel();
    _sub = _repo.watchBookings(_auth.currentUid ?? '').listen(
          (list) {
        bookings.assignAll(list);
        isLoading.value = false;
      },
      onError: (e, s) {
        errorMessage.value = ExceptionHandler.message(e, s);
        isLoading.value = false;
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<BookingModel> get filtered => bookings.where((b) {
    if (statusFilter.value != null && b.status != statusFilter.value) {
      return false;
    }
    if (seaterFilter.value != null && b.seater != seaterFilter.value) {
      return false;
    }
    if (dateFilter.value != null &&
        !_sameDay(b.checkInDate, dateFilter.value!)) {
      return false;
    }
    return true;
  }).toList();

  // ---- Stats ----
  int get totalBookings => bookings.length;
  int get pendingRequests =>
      bookings.where((b) => b.status == BookingStatus.pending).length;
  int get approvedBookings =>
      bookings.where((b) => b.status == BookingStatus.approved).length;
  int get newCheckIns {
    final now = DateTime.now();
    return bookings
        .where((b) =>
    b.status == BookingStatus.approved &&
        b.checkInDate.year == now.year &&
        b.checkInDate.month == now.month)
        .length;
  }

  Future<void> pickDateFilter() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: dateFilter.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) dateFilter.value = picked;
  }

  void clearDateFilter() => dateFilter.value = null;

  void openCreate() => Get.toNamed(AppRoutes.bookingForm);

  Future<void> onAction(BookingModel b, BookingAction action) async {
    switch (action) {
      case BookingAction.viewDetails:
        Get.dialog(BookingDetailsDialog(booking: b));
        break;
      case BookingAction.approve:
        await _approve(b);
        break;
      case BookingAction.reject:
        await _reject(b);
        break;
    }
  }

  Future<void> _approve(BookingModel b) async {
    if (!b.isPending) {
      AppSnackbar.info('This booking is already ${b.status.label}.');
      return;
    }
    final ok = await AppDialogs.confirm(
      title: 'Approve booking?',
      message:
      '${b.studentName} will be added to Room ${b.roomNumber}, bed ${b.bed}.',
      confirmText: 'Approve',
    );
    if (ok != true) return;

    try {
      await NetworkManager.instance.ensureConnected();
      await _repo.approve(b);
      AppSnackbar.success('Booking approved');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  Future<void> _reject(BookingModel b) async {
    if (!b.isPending) {
      AppSnackbar.info('This booking is already ${b.status.label}.');
      return;
    }
    final ok = await AppDialogs.confirm(
      title: 'Reject booking?',
      message: 'The request from ${b.studentName} will be rejected.',
      confirmText: 'Reject',
      isDestructive: true,
    );
    if (ok != true) return;

    try {
      await NetworkManager.instance.ensureConnected();
      await _repo.reject(b);
      AppSnackbar.success('Booking rejected');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}