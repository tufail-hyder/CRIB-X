import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

class StudentFormController extends GetxController {
  final StudentRepository _repo;
  final RoomRepository _roomRepo;
  final AuthRepository _auth;
  StudentFormController(this._repo, this._roomRepo, this._auth);

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  final rooms = <RoomModel>[].obs; // sirf jinme bed khali ho
  final isLoadingRooms = true.obs;
  final isSaving = false.obs;

  final selectedRoomId = RxnString();
  final selectedBed = RxnString();
  final checkIn = DateTime.now().obs;
  final paymentStatus = PaymentStatus.pending.obs;

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
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

      final cnic = cnicCtrl.text.trim();
      await _repo.addStudent(StudentModel(
        id: '',
        hostelId: _auth.currentUid ?? '',
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        cnic: cnic.isEmpty ? null : cnic,
        roomId: room.id,
        roomNumber: room.roomNumber,
        bed: bed,
        checkInDate: checkIn.value,
        paymentStatus: paymentStatus.value,
      ));

      Get.back();
      AppSnackbar.success('Student added to Room ${room.roomNumber} ($bed)');
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
    cnicCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }
}