import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/custom_text_field.dart';
import '../controllers/signup_controller.dart';

class AdminSignupView extends GetView<SignupController> {
  const AdminSignupView({super.key});

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
                      const SizedBox(height: 24),
                      Text('Sign up',
                          style: AppTextStyles.screenTitle.copyWith(
                              fontSize: 36, fontWeight: FontWeight.w700)),
                      AppSizes.hSm,
                      Text('Create your Hostel Account',
                          style: AppTextStyles.body),
                      const SizedBox(height: 24),
                      CustomTextField(
                        hint: 'Hostel',
                        controller: controller.hostelCtrl,
                        validator: (v) =>
                            Validators.required(v, 'Hostel name'),
                      ),
                      AppSizes.hMd,
                      CustomTextField(
                        hint: 'City',
                        controller: controller.cityCtrl,
                        validator: (v) => Validators.required(v, 'City'),
                      ),
                      AppSizes.hMd,
                      CustomTextField(
                        hint: 'Owner Name',
                        controller: controller.ownerCtrl,
                        validator: (v) => Validators.required(v, 'Name'),
                      ),
                      AppSizes.hMd,
                      CustomTextField(
                        hint: 'Email',
                        controller: controller.emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      AppSizes.hMd,
                      CustomTextField(
                        hint: 'Phone Number',
                        controller: controller.phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      AppSizes.hMd,
                      CustomTextField(
                        hint: 'CNIC (without dashes)',
                        controller: controller.cnicCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 13,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: Validators.cnic,
                      ),
                      AppSizes.hMd,
                      CustomTextField(
                        hint: 'Password',
                        controller: controller.passwordCtrl,
                        isPassword: true,
                        validator: Validators.password,
                      ),
                      AppSizes.hMd,
                      CustomTextField(
                        hint: 'Confirm Password',
                        controller: controller.confirmCtrl,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.confirmPassword(
                                () => controller.passwordCtrl.text),
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
                    isLoading: controller.isLoading.value,
                    onPressed: controller.signup,
                  )),
                  AppSizes.hLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Do you have account. ',
                          style: AppTextStyles.body),
                      GestureDetector(
                        onTap: Get.back,
                        child: Text('login',
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