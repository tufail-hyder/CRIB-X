import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

class StudentSignupController extends GetxController {
  final AuthRepository _auth;
  StudentSignupController(this._auth);

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final isLoading = false.obs;

  String? validateCnic(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length == 13 ? null : 'Enter a valid CNIC (13 digits)';
  }

  String? validateConfirm(String? v) =>
      v != passCtrl.text ? 'Passwords do not match' : null;

  /// 13 digits ho to 12345-1234567-1
  String _formatCnic(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length != 13) return raw.trim();
    return '${d.substring(0, 5)}-${d.substring(5, 12)}-${d.substring(12)}';
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      await NetworkManager.instance.ensureConnected();
      await _auth.registerStudent(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
        phone: phoneCtrl.text.trim(),
        cnic: _formatCnic(cnicCtrl.text),
      );
      Get.offAllNamed(AppRoutes.studentHome);
      AppSnackbar.success('Account created. Welcome to CRIB X!');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.back();

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    cnicCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}