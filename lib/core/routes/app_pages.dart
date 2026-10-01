import 'package:get/get.dart';
import '../../modules/admin/dashboard/views/dashboard_view.dart';
import '../../modules/admin/widgets/admin_menu.dart';
import '../../modules/admin/widgets/coming_soon_view.dart';
import '../binding/dashboard_binding.dart';
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
  ];
}