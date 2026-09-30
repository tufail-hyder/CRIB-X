import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/exceptions/exception_handler.dart';
import '../../../core/network/network_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/popups/app_snackbar.dart';

class LoginController extends GetxController {
  final AuthRepository _repo;
  LoginController(this._repo);

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    try {
      isLoading.value = true;
      await NetworkManager.instance.ensureConnected();
      await _repo.loginAdmin(emailCtrl.text.trim(), passwordCtrl.text);
      Get.offAllNamed(AppRoutes.adminDashboard);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final error = Validators.email(emailCtrl.text);
    if (error != null) {
      AppSnackbar.warning('Enter your email first, then tap Forget Password.');
      return;
    }
    try {
      await NetworkManager.instance.ensureConnected();
      await _repo.sendPasswordReset(emailCtrl.text.trim());
      AppSnackbar.success('Password reset link sent to your email.');
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}