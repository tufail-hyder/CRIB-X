import 'package:get/get.dart';
import '../controllers/room_form_controller.dart';
import '../controllers/rooms_controller.dart';

class RoomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RoomsController(Get.find(), Get.find()));
  }
}

class RoomFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RoomFormController(Get.find(), Get.find()));
  }
}