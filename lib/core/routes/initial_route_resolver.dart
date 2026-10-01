import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../utils/logger.dart';
import 'app_routes.dart';

class InitialRouteResolver {
  InitialRouteResolver._();

  static Future<String> resolve() async {
    final repo = Get.find<AuthRepository>();
    if (!repo.isLoggedIn) return AppRoutes.adminLogin;

    try {
      final user =
      await repo.getCurrentUser().timeout(const Duration(seconds: 8));

      if (user == null) {
        await repo.logout(); // auth hai lekin profile nahi
        return AppRoutes.adminLogin;
      }
      if (user.isAdmin) return AppRoutes.adminDashboard;
      // TODO: student screens banne par student route yahan aayega
    } catch (e, s) {
      AppLogger.e('Initial route check failed', e, s);
    }
    return AppRoutes.adminLogin;
  }
}