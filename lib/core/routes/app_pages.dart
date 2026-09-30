import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/admin_login_view.dart';
import '../../modules/auth/views/admin_signup_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.adminLogin,
      page: () => const AdminLoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.adminSignup,
      page: () => const AdminSignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const Scaffold(body: Center(child: Text('Dashboard'))),
    ),
  ];
}