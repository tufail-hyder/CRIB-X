import 'package:get/get.dart';
import '../controllers/student_controllers.dart';
import '../controllers/student_form_controller.dart';

class StudentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentsController(Get.find(), Get.find(), Get.find()));
  }
}

class StudentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentFormController(Get.find(), Get.find(), Get.find()));
  }
}