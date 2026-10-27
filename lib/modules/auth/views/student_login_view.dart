import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../controllers/student_login_controller.dart';

class StudentLoginView extends GetView<StudentLoginController> {
  const StudentLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Text('Login',
                          style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 36, fontWeight: FontWeight.w700)),
                      AppSizes.hSm,
                      Text('Login to access your account',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body),
                      const SizedBox(height: 32),
                      CustomTextField(
                        hint: 'Email',
                        controller: c.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      AppSizes.hLg,
                      CustomTextField(
                        hint: 'Password',
                        controller: c.passCtrl,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) => Validators.required(v, 'Password'),
                      ),
                      AppSizes.hSm,
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: c.forgotPassword,
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
                    isLoading: c.isLoading.value,
                    onPressed: c.login,
                  )),
                  AppSizes.hLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account. ", style: AppTextStyles.body),
                      GestureDetector(
                        onTap: c.goToSignup,
                        child: Text('Sign up',
                            style: AppTextStyles.oneLinerSemiBold),
                      ),
                    ],
                  ),
                  AppSizes.hMd,
                  GestureDetector(
                    onTap: c.goToAdminLogin,
                    child: Text(
                      'Hostel owner? Login here',
                      style: AppTextStyles.smallRegular
                          .copyWith(color: AppColors.gray600),
                    ),
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