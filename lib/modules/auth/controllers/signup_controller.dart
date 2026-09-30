import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/exceptions/exception_handler.dart';
import '../../../core/network/network_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/popups/app_snackbar.dart';

class SignupController extends GetxController {
  final AuthRepository _repo;
  SignupController(this._repo);

  final formKey = GlobalKey<FormState>();
  final hostelCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final ownerCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;
    try {
      isLoading.value = true;
      await NetworkManager.instance.ensureConnected();
      await _repo.registerAdmin(
        ownerName: ownerCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        phone: phoneCtrl.text.trim(),
        cnic: cnicCtrl.text.trim(),
        hostelName: hostelCtrl.text.trim(),
        city: cityCtrl.text.trim(),
      );
      AppSnackbar.success('Account created successfully');
      Get.offAllNamed(AppRoutes.adminDashboard);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    hostelCtrl.dispose();
    cityCtrl.dispose();
    ownerCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    cnicCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}