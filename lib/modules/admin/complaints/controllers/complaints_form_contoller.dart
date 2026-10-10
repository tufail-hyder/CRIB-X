import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../data/models/complaint_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/complaint_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

class ComplaintFormController extends GetxController {
  final ComplaintRepository _repo;
  final StudentRepository _studentRepo;
  final AuthRepository _auth;
  ComplaintFormController(this._repo, this._studentRepo, this._auth);

  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final students = <StudentModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  final selectedStudentId = RxnString();
  final category = ComplaintCategory.maintenance.obs;
  final priority = ComplaintPriority.medium.obs;

  StudentModel? get selectedStudent =>
      students.firstWhereOrNull((s) => s.id == selectedStudentId.value);

  @override
  void onInit() {
    super.onInit();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final all =
      await _studentRepo.watchStudents(_auth.currentUid ?? '').first;
      students.assignAll(all.where((s) => s.isActive));
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final student = selectedStudent;
    if (student == null) return;

    try {
      isSaving.value = true;
      await NetworkManager.instance.ensureConnected();

      await _repo.createComplaint(ComplaintModel(
        id: '',
        hostelId: _auth.currentUid ?? '',
        studentId: student.id,
        studentName: student.name,
        roomNumber: student.roomNumber,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        category: category.value,
        priority: priority.value,
        createdAt: DateTime.now(),
      ));

      Get.back();
      AppSnackbar.success('Complaint created');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}