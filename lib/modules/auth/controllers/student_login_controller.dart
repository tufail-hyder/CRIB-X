import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

class StudentLoginController extends GetxController {
  final AuthRepository _auth;
  StudentLoginController(this._auth);

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      await NetworkManager.instance.ensureConnected();
      await _auth.loginStudent(emailCtrl.text.trim(), passCtrl.text);
      Get.offAllNamed(AppRoutes.studentHome);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final email = emailCtrl.text.trim();
    if (Validators.email(email) != null) {
      AppSnackbar.warning('Enter your email above first.');
      return;
    }
    try {
      await NetworkManager.instance.ensureConnected();
      await _auth.sendPasswordReset(email);
      AppSnackbar.success('Password reset link sent to $email');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  void goToSignup() => Get.toNamed(AppRoutes.studentSignup);
  void goToAdminLogin() => Get.offAllNamed(AppRoutes.adminLogin);

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}