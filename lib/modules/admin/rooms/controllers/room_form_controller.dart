import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';

class RoomFormController extends GetxController {
  final RoomRepository _repo;
  final AuthRepository _auth;
  RoomFormController(this._repo, this._auth);

  final formKey = GlobalKey<FormState>();
  final numberCtrl = TextEditingController();
  final bedsCtrl = TextEditingController(text: '2');
  final priceCtrl = TextEditingController();

  final seater = 2.obs;
  final isReserved = false.obs;
  final isSaving = false.obs;

  RoomModel? _editing;
  bool get isEdit => _editing != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RoomModel) {
      _editing = args;
      numberCtrl.text = args.roomNumber;
      seater.value = args.seater;
      bedsCtrl.text = '${args.totalBeds}';
      priceCtrl.text = args.monthlyPrice.toStringAsFixed(0);
      isReserved.value = args.status == RoomStatus.reserved;
    }
  }

  void onSeaterChanged(int? v) {
    if (v == null) return;
    seater.value = v;
    bedsCtrl.text = '$v'; // default: beds = seater
  }

  String? validateBeds(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'Enter valid number of beds';
    final occupied = _editing?.occupiedBeds ?? 0;
    if (n < occupied) return '$occupied beds are already occupied';
    return null;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();

      final room = RoomModel(
        id: _editing?.id ?? '',
        hostelId: _auth.currentUid ?? '',
        roomNumber: numberCtrl.text.trim(),
        seater: seater.value,
        totalBeds: int.parse(bedsCtrl.text.trim()),
        occupiedBeds: _editing?.occupiedBeds ?? 0,
        monthlyPrice: double.parse(priceCtrl.text.trim()),
        status: isReserved.value ? RoomStatus.reserved : RoomStatus.available,
      );

      isEdit ? await _repo.updateRoom(room) : await _repo.addRoom(room);

      Get.back();
      AppSnackbar.success(isEdit ? 'Room updated' : 'Room added');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete() async {
    final room = _editing;
    if (room == null) return;

    if (room.occupiedBeds > 0) {
      AppSnackbar.warning('Room has students. Move them out first.');
      return;
    }
    final ok = await AppDialogs.confirmDelete('Room ${room.roomNumber}');
    if (ok != true) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();
      await _repo.deleteRoom(room.hostelId, room.id);
      Get.back();
      AppSnackbar.success('Room deleted');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    numberCtrl.dispose();
    bedsCtrl.dispose();
    priceCtrl.dispose();
    super.onClose();
  }
}