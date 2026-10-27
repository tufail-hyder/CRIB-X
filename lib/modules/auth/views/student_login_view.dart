import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/student_auth_field.dart';
import '../widgets/student_auth_scaffold.dart';
import '../controllers/student_login_controller.dart';

class StudentLoginView extends GetView<StudentLoginController> {
  const StudentLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return StudentAuthScaffold(
      title: 'Login',
      subtitle: 'Login to access your  account',
      form: Form(
        key: c.formKey,
        child: Column(
          children: [
            StudentAuthField(
              hint: 'Email',
              controller: c.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            StudentAuthField(
              hint: 'Password',
              controller: c.passCtrl,
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (v) => Validators.required(v, 'Password'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: c.forgotPassword,
                child: const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Text('Forget Password?',
                      style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                ),
              ),
            ),
          ],
        ),
      ),
      footer: Column(
        children: [
          Obx(() => StudentAuthButton(
            text: 'Login',
            isLoading: c.isLoading.value,
            onPressed: c.login,
          )),
          const SizedBox(height: 16),
          StudentAuthSwitchLine(
            text: "Don't have account.",
            action: 'Sign up',
            onTap: c.goToSignup,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: c.goToAdminLogin,
            child: const Text('Hostel owner? Login here',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }
}