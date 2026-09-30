import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/custom_text_field.dart';
import '../controllers/login_controller.dart';

class AdminLoginView extends GetView<LoginController> {
  const AdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Text('Login',
                          style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 36, fontWeight: FontWeight.w700)),
                      AppSizes.hSm,
                      Text('Login to access your hostel account',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body),
                      const SizedBox(height: 32),
                      CustomTextField(
                        hint: 'Email',
                        controller: controller.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      AppSizes.hLg,
                      CustomTextField(
                        hint: 'Password',
                        controller: controller.passwordCtrl,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) =>
                            Validators.required(v, 'Password'),
                      ),
                      AppSizes.hSm,
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: controller.forgotPassword,
                          child: Text('Forget Password?',
                              style: AppTextStyles.smallSemiBold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.xl, 0, AppSizes.xl, AppSizes.xl),
              child: Column(
                children: [
                  Obx(() => PrimaryButton(
                    text: 'Login',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.login,
                  )),
                  AppSizes.hLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account. ",
                          style: AppTextStyles.body),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.adminSignup),
                        child: Text('Sign up',
                            style: AppTextStyles.oneLinerSemiBold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}