import 'package:crib_x/modules/auth/views/admin_signup_view.dart';
import 'package:get/get.dart';
import '../../modules/admin/dashboard/views/dashboard_view.dart';
import '../../modules/admin/hostel_profile/views/hostel_profile_view.dart';
import '../../modules/admin/widgets/admin_menu.dart';
import '../../modules/admin/widgets/coming_soon_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/admin_login_view.dart';
import '../binding/dashboard_binding.dart';
import '../binding/hostel_profile_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final _implemented = {
    AppRoutes.adminDashboard,
    AppRoutes.adminHostelProfile,
  };

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
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.adminHostelProfile,
      page: () => const HostelProfileView(),
      binding: HostelProfileBinding(),
    ),

    ...adminMenu
        .where((m) => !_implemented.contains(m.route))
        .map((m) => GetPage(
      name: m.route,
      page: () => ComingSoonView(title: m.title),
    )),
  ];
}