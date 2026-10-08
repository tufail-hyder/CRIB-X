import 'package:crib_x/modules/auth/views/admin_signup_view.dart';
import 'package:get/get.dart';
import '../../modules/admin/bookings/bindings/booking_bindind.dart';
import '../../modules/admin/bookings/views/booking_form_view.dart';
import '../../modules/admin/bookings/views/booking_views.dart';
import '../../modules/admin/dashboard/views/dashboard_view.dart';
import '../../modules/admin/hostel_profile/views/hostel_profile_view.dart';
import '../../modules/admin/payments/bindings/payment_binding.dart';
import '../../modules/admin/payments/views/payment_form_view.dart';
import '../../modules/admin/payments/views/payments_view.dart';
import '../../modules/admin/rooms/bindings/rooms_binding.dart';
import '../../modules/admin/rooms/views/add_room_view.dart';
import '../../modules/admin/rooms/views/rooms_view.dart';
import '../../modules/admin/students/bindings/student_binding.dart';
import '../../modules/admin/students/views/student_form_view.dart';
import '../../modules/admin/students/views/student_view.dart';
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
    AppRoutes.adminStudents,
    AppRoutes.adminBookings,
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
    GetPage(
      name: AppRoutes.adminStudents,
      page: () => const StudentsView(),
      binding: StudentsBinding(),
    ),
    GetPage(
      name: AppRoutes.studentForm,
      page: () => const StudentFormView(),
      binding: StudentFormBinding(),
    ),
    GetPage(
      name: AppRoutes.adminBookings,
      page: () => const BookingsView(),
      binding: BookingsBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingForm,
      page: () => const BookingFormView(),
      binding: BookingFormBinding(),
    ),
  GetPage(
  name: AppRoutes.adminPayments,
  page: () => const PaymentsView(),
  binding: PaymentsBinding(),
   ),
  GetPage(
  name: AppRoutes.paymentForm,
  page: () => const PaymentFormView(),
  binding: PaymentFormBinding(),
   ),

    ...adminMenu
        .where((m) => !_implemented.contains(m.route))
        .map((m) => GetPage(
      name: m.route,
      page: () => ComingSoonView(title: m.title),
    )),
  ];
}