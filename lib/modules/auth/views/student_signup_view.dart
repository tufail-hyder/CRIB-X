import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../controllers/student_signup_controller.dart';

class StudentSignupView extends GetView<StudentSignupController> {
  const StudentSignupView({super.key});

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
                      Text('Sign up',
                          style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 36, fontWeight: FontWeight.w700)),
                      AppSizes.hSm,
                      Text('Create your account',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body),
                      const SizedBox(height: 32),
                      CustomTextField(
                        hint: 'Full Name',
                        controller: c.nameCtrl,
                        validator: (v) => Validators.required(v, 'Name'),
                      ),
                      AppSizes.hLg,
                      CustomTextField(
                        hint: 'Email',
                        controller: c.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      AppSizes.hLg,
                      CustomTextField(
                        hint: 'Phone Number',
                        controller: c.phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      AppSizes.hLg,
                      CustomTextField(
                        hint: 'CNIC',
                        controller: c.cnicCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 15,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                        ],
                        validator: c.validateCnic,
                      ),
                      AppSizes.hLg,
                      CustomTextField(
                        hint: 'Password',
                        controller: c.passCtrl,
                        isPassword: true,
                        validator: (v) =>
                            Validators.minLength(v, 6, 'Password'),
                      ),
                      AppSizes.hLg,
                      CustomTextField(
                        hint: 'Confirm Password',
                        controller: c.confirmCtrl,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: c.validateConfirm,
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
                    text: 'Sign up',
                    isLoading: c.isLoading.value,
                    onPressed: c.signup,
                  )),
                  AppSizes.hLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Do you have account. ',
                          style: AppTextStyles.body),
                      GestureDetector(
                        onTap: c.goToLogin,
                        child: Text('Login',
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