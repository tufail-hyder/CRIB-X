import 'package:get/get.dart';
import '../controllers/payment_controller.dart';
import '../controllers/payment_form_controller.dart';

class PaymentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentsController(Get.find(), Get.find(), Get.find()));
  }
}

class PaymentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
            () => PaymentFormController(Get.find(), Get.find(), Get.find(), Get.find()));
  }
}