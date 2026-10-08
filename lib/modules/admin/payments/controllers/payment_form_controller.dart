import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/date_text.dart';
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
  late final RxString forMonth;

  /// roomId -> monthly price (amount pehle se bharne ke liye)
  final _roomPrice = <String, double>{};

  /// Aakhri 6 mahine (aaj ka mahina pehle)
  late final List<DateTime> monthOptions;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    monthOptions = [for (var i = 0; i < 6; i++) DateTime(now.year, now.month - i, 1)];
    forMonth = PaymentModel.monthKey(now).obs;

    final preselected = Get.arguments is StudentModel
        ? (Get.arguments as StudentModel)
        : null;
    _load(preselected);
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

      if (preselected != null &&
          students.any((s) => s.id == preselected.id)) {
        onStudentChanged(preselected.id);
      }
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isLoading.value = false;
    }
  }

  StudentModel? get selectedStudent =>
      students.firstWhereOrNull((s) => s.id == selectedStudentId.value);

  void onStudentChanged(String? id) {
    selectedStudentId.value = id;
    final price = _roomPrice[selectedStudent?.roomId];
    if (price != null && price > 0) {
      amountCtrl.text = price.toStringAsFixed(0);
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final student = selectedStudent;
    if (student == null) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();

      final note = noteCtrl.text.trim();
      final now = DateTime.now();

      await _repo.recordPayment(
        PaymentModel(
          id: '',
          hostelId: _auth.currentUid ?? '',
          studentId: student.id,
          studentName: student.name,
          roomNumber: student.roomNumber,
          amount: double.parse(amountCtrl.text.trim()),
          method: method.value,
          forMonth: forMonth.value,
          note: note.isEmpty ? null : note,
          paidAt: now,
        ),
        markStudentPaid: forMonth.value == PaymentModel.monthKey(now),
      );

      Get.back();
      AppSnackbar.success('Payment recorded for ${student.name}');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  String monthLabel(DateTime d) => monthText(d);

  @override
  void onClose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}