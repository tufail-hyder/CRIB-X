import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

class BookingFormController extends GetxController {
  final BookingRepository _repo;
  final RoomRepository _roomRepo;
  final AuthRepository _auth;
  BookingFormController(this._repo, this._roomRepo, this._auth);

  static const durations = [1, 2, 3, 6, 9, 12];

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  final rooms = <RoomModel>[].obs; // sirf jinme bed khali ho
  final isLoadingRooms = true.obs;
  final isSaving = false.obs;

  final selectedRoomId = RxnString();
  final selectedBed = RxnString();
  final checkIn = DateTime.now().obs;
  final duration = 6.obs;

  RoomModel? get selectedRoom =>
      rooms.firstWhereOrNull((r) => r.id == selectedRoomId.value);

  List<String> get freeBeds => selectedRoom?.freeBedLabels ?? const [];

  @override
  void onInit() {
    super.onInit();
    dateCtrl.text = dateText(checkIn.value);
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final all = await _roomRepo.watchRooms(_auth.currentUid ?? '').first;
      rooms.assignAll(all.where((r) => r.availableBeds > 0));
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isLoadingRooms.value = false;
    }
  }

  void onRoomChanged(String? id) {
    selectedRoomId.value = id;
    selectedBed.value = null;
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: checkIn.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    checkIn.value = picked;
    dateCtrl.text = dateText(picked);
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final room = selectedRoom;
    final bed = selectedBed.value;
    if (room == null || bed == null) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();

      await _repo.createBooking(BookingModel(
        id: '',
        hostelId: _auth.currentUid ?? '',
        studentName: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        roomId: room.id,
        roomNumber: room.roomNumber,
        seater: room.seater,
        bed: bed,
        checkInDate: checkIn.value,
        durationMonths: duration.value,
      ));

      Get.back();
      AppSnackbar.success('Booking created. Approve it to assign the bed.');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }
}