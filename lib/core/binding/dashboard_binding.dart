import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/dashboard_repository.dart';
import '../../modules/admin/dashboard/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardRepository());
    Get.lazyPut(() => DashboardController(
      Get.find<DashboardRepository>(),
      Get.find<AuthRepository>(),
    ));
  }
}