import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import '../controllers/booking_form_controller.dart';

class BookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookingsController(Get.find(), Get.find()));
  }
}

class BookingFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookingFormController(Get.find(), Get.find(), Get.find()));
  }
}