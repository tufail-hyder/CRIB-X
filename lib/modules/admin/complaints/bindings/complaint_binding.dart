import 'package:get/get.dart';

import '../controllers/compaints_controller.dart';
import '../controllers/complaints_form_contoller.dart';

class ComplaintsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ComplaintsController(Get.find(), Get.find()));
  }
}

class ComplaintFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ComplaintFormController(Get.find(), Get.find(), Get.find()));
  }
}