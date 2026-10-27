import 'package:get/get.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../modules/admin/dashboard/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardRepository(Get.find(), Get.find(), Get.find()));
    Get.lazyPut(() => DashboardController(Get.find(), Get.find()));
  }
}