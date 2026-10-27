import 'package:get/get.dart';
import '../controllers/student_login_controller.dart';
import '../controllers/student_signup_controller.dart';

class StudentLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentLoginController(Get.find()));
  }
}

class StudentSignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentSignupController(Get.find()));
  }
}