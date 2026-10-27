import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import 'app_routes.dart';

class InitialRouteResolver {
  InitialRouteResolver._();

  static Future<String> resolve() async {
    final auth = Get.find<AuthRepository>();

    if (!auth.isLoggedIn) return AppRoutes.adminLogin;

    try {
      final user = await auth.getCurrentUser();

      if (user == null) {
        await auth.logout();
        return AppRoutes.adminLogin;
      }

      return user.isAdmin ? AppRoutes.adminDashboard : AppRoutes.studentHome;
    } catch (_) {
      return AppRoutes.adminLogin;
    }
  }
}