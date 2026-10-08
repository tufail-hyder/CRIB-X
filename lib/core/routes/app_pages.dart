import 'package:crib_x/modules/auth/views/admin_signup_view.dart';
import 'package:get/get.dart';
import '../../modules/admin/dashboard/views/dashboard_view.dart';
import '../../modules/admin/hostel_profile/views/hostel_profile_view.dart';
import '../../modules/admin/rooms/bindings/rooms_binding.dart';
import '../../modules/admin/rooms/views/add_room_view.dart';
import '../../modules/admin/rooms/views/rooms_view.dart';
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
    AppRoutes.adminRooms,
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
    GetPage(
      name: AppRoutes.adminRooms,
      page: () => const RoomsView(),
      binding: RoomsBinding(),
    ),
    GetPage(
      name: AppRoutes.roomForm,
      page: () => const RoomFormView(),
      binding: RoomFormBinding(),
    ),

    ...adminMenu
        .where((m) => !_implemented.contains(m.route))
        .map((m) => GetPage(
      name: m.route,
      page: () => ComingSoonView(title: m.title),
    )),
  ];
}