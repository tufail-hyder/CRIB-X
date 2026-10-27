import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/student_signup_controller.dart';
import '../widgets/student_auth_field.dart';
import '../widgets/student_auth_scaffold.dart';

class StudentSignupView extends GetView<StudentSignupController> {
  const StudentSignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return StudentAuthScaffold(
      title: 'Sign up',
      subtitle: 'Create your account',
      form: Form(
        key: c.formKey,
        child: Column(
          children: [
            StudentAuthField(
              hint: 'Full Name',
              controller: c.nameCtrl,
              validator: (v) => Validators.required(v, 'Name'),
            ),
            const SizedBox(height: 12),
            StudentAuthField(
              hint: 'Email',
              controller: c.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            StudentAuthField(
              hint: 'Phone Number',
              controller: c.phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),
            const SizedBox(height: 12),
            StudentAuthField(
              hint: 'CNIC',
              controller: c.cnicCtrl,
              keyboardType: TextInputType.number,
              maxLength: 15,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
              ],
              validator: c.validateCnic,
            ),
            const SizedBox(height: 12),
            StudentAuthField(
              hint: 'Password',
              controller: c.passCtrl,
              isPassword: true,
              validator: (v) => Validators.minLength(v, 6, 'Password'),
            ),
            const SizedBox(height: 12),
            StudentAuthField(
              hint: 'Confirm Password',
              controller: c.confirmCtrl,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: c.validateConfirm,
            ),
          ],
        ),
      ),
      footer: Column(
        children: [
          Obx(() => StudentAuthButton(
            text: 'Sign up',
            isLoading: c.isLoading.value,
            onPressed: c.signup,
          )),
          const SizedBox(height: 16),
          StudentAuthSwitchLine(
            text: 'Do you have account.',
            action: 'Login',
            onTap: c.goToLogin,
          ),
        ],
      ),
    );
  }
}