import 'package:get/get.dart';
import '../controllers/setting_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // SettingsRepository, AuthRepository
    Get.lazyPut(() => SettingsController(Get.find(), Get.find()));
  }
}