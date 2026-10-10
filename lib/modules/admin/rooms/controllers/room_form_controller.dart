import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';

/// Add aur Edit dono ke liye. Edit me Get.arguments me RoomModel aata hai.
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

  /// Students ke record me room number copy hota hai, isliye jab tak koi
  /// rehta hai tab tak rename nahi.
  String? validateNumber(String? v) {
    final err = Validators.required(v, 'Room number');
    if (err != null) return err;
    final e = _editing;
    if (e != null && e.occupiedBeds > 0 && v!.trim() != e.roomNumber) {
      return 'Cannot rename a room while students are living in it';
    }
    return null;
  }

  /// Total beds us bed se kam nahi ho sakte jo bhara hua hai (A3 bhara ho to min 3).
  String? validateBeds(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'Enter valid number of beds';

    final labels = _editing?.occupiedBedLabels ?? const <String>[];
    final highest = labels
        .map((l) => int.tryParse(l.substring(1)) ?? 0)
        .fold<int>(0, math.max);
    if (n < highest) {
      return 'Bed A$highest is occupied, total beds cannot be less than $highest';
    }
    return null;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    // Reserved = khali room roka hua. Jis me students hain wo reserve nahi.
    if (isReserved.value && (_editing?.occupiedBeds ?? 0) > 0) {
      AppSnackbar.warning('A room with students cannot be marked as reserved.');
      return;
    }

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
        occupiedBedLabels: _editing?.occupiedBedLabels ?? const [],
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