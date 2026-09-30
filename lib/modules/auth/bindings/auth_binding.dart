import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../controllers/signup_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(Get.find<AuthRepository>()));
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignupController(Get.find<AuthRepository>()));
  }
}