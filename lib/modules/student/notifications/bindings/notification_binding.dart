import 'package:get/get.dart';

import '../../../../data/models/notification_model.dart';
import '../controllers/notification_controller.dart';

class StudentNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationsController(
        Get.find(), Get.find(), Get.find(), Get.find(), NotificationScope.student));
  }
}

class AdminNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationsController(
        Get.find(), Get.find(), Get.find(), Get.find(), NotificationScope.admin));
  }
}