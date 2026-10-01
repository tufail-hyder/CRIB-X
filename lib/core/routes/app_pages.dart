import 'package:get/get.dart';
import '../../modules/admin/dashboard/views/dashboard_view.dart';
import '../../modules/admin/hostel_profile/views/hostel_profile_view.dart';
import '../../modules/admin/widgets/admin_menu.dart';
import '../../modules/admin/widgets/coming_soon_view.dart';
import '../binding/dashboard_binding.dart';
import '../binding/hostel_profile_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    ...adminMenu
        .where((m) => m.route != AppRoutes.adminDashboard)
        .map((m) => GetPage(
      name: m.route,
      page: () => ComingSoonView(title: m.title),
    )),

    GetPage(
      name: AppRoutes.adminHostelProfile,
      page: () => const HostelProfileView(),
      binding: HostelProfileBinding(),
    ),
    ...adminMenu
        .where((m) =>
    m.route != AppRoutes.adminDashboard &&
        m.route != AppRoutes.adminHostelProfile)
        .map((m) => GetPage(
      name: m.route,
      page: () => ComingSoonView(title: m.title),
    )),
  ];
}