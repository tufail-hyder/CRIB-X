import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/payment_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

class PaymentFormController extends GetxController {
  final PaymentRepository _repo;
  final StudentRepository _studentRepo;
  final RoomRepository _roomRepo;
  final AuthRepository _auth;
  PaymentFormController(
      this._repo, this._studentRepo, this._roomRepo, this._auth);

  final formKey = GlobalKey<FormState>();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  final students = <StudentModel>[].obs; // sirf active
  final isLoading = true.obs;
  final isSaving = false.obs;

  final selectedStudentId = RxnString();
  final method = PaymentMethod.cash.obs;
  final forMonth = StudentModel.monthKey(DateTime.now()).obs;

  /// roomId -> price (purane students jinki fee save nahi thi unke liye)
  final _roomPrice = <String, double>{};

  StudentModel? get selectedStudent =>
      students.firstWhereOrNull((s) => s.id == selectedStudentId.value);

  /// Is student ki mahana fees
  double get fee {
    final s = selectedStudent;
    if (s == null) return 0;
    return s.monthlyFee > 0 ? s.monthlyFee : (_roomPrice[s.roomId] ?? 0);
  }

  double get paidSoFar => selectedStudent?.paidFor(forMonth.value) ?? 0;

  double get remaining => fee > 0 ? math.max(0.0, fee - paidSoFar) : 0;

  /// Check-in se pehle ke mahine nahi, aakhri 6 mahine + agla mahina (advance)
  List<DateTime> get monthOptions {
    final now = DateTime.now();
    final s = selectedStudent;

    var first = DateTime(now.year, now.month - 5, 1);
    var top = DateTime(now.year, now.month + 1, 1);
    if (s != null) {
      final cin = DateTime(s.checkInDate.year, s.checkInDate.month, 1);
      if (cin.isAfter(first)) first = cin;
      if (cin.isAfter(top)) top = cin;
    }

    final list = <DateTime>[];
    for (var m = top; !m.isBefore(first); m = DateTime(m.year, m.month - 1, 1)) {
      list.add(m);
    }
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    _load(arg is StudentModel ? arg : null);
  }

  Future<void> _load(StudentModel? preselected) async {
    try {
      final uid = _auth.currentUid ?? '';
      final all = await _studentRepo.watchStudents(uid).first;
      final rooms = await _roomRepo.watchRooms(uid).first;

      for (final r in rooms) {
        _roomPrice[r.id] = r.monthlyPrice;
      }
      students.assignAll(all.where((s) => s.isActive));

      if (preselected != null && students.any((s) => s.id == preselected.id)) {
        onStudentChanged(preselected.id);
      }
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isLoading.value = false;
    }
  }

  void onStudentChanged(String? id) {
    selectedStudentId.value = id;
    final s = selectedStudent;
    final now = DateTime.now();
    // Future check-in ho to uska pehla mahina, warna is mahine ki fees
    forMonth.value = StudentModel.monthKey(
        (s != null && s.checkInDate.isAfter(now)) ? s.checkInDate : now);
    _prefillAmount();
  }

  void onMonthChanged(String? key) {
    if (key == null) return;
    forMonth.value = key;
    _prefillAmount();
  }

  /// Baqi raqam khud bhar do (admin kam kar sakta hai = partial payment)
  void _prefillAmount() {
    final rem = remaining;
    amountCtrl.text = rem > 0 ? rem.toStringAsFixed(0) : '';
  }

  String? validateAmount(String? v) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'Enter a valid amount';
    if (fee > 0) {
      if (remaining <= 0) return 'This month is already fully paid';
      if (n > remaining) {
        return 'Cannot be more than remaining (${remaining.toStringAsFixed(0)})';
      }
    }
    return null;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final student = selectedStudent;
    if (student == null) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();

      final amount = double.parse(amountCtrl.text.trim());
      final note = noteCtrl.text.trim();
      final leftAfter = fee > 0 ? remaining - amount : 0;

      await _repo.recordPayment(
        PaymentModel(
          id: '',
          hostelId: _auth.currentUid ?? '',
          studentId: student.id,
          studentName: student.name,
          roomNumber: student.roomNumber,
          amount: amount,
          method: method.value,
          forMonth: forMonth.value,
          note: note.isEmpty ? null : note,
          paidAt: DateTime.now(),
        ),
        fallbackFee: fee,
      );

      Get.back();
      AppSnackbar.success(leftAfter > 0
          ? 'Payment recorded. ${leftAfter.toStringAsFixed(0)} still remaining for ${student.name}.'
          : 'Payment recorded. ${student.name} is fully paid for this month.');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}