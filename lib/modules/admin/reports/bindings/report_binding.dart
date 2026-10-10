import 'package:get/get.dart';
import '../controllers/report_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    // payments, complaints, students, rooms, auth
    Get.lazyPut(() => ReportsController(
      Get.find(),
      Get.find(),
      Get.find(),
      Get.find(),
      Get.find(),
    ));
  }
}