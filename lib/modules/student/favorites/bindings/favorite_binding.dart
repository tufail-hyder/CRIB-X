import 'package:get/get.dart';

import '../controllers/favorite_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    // StudentHomeRepository, AuthRepository
    Get.lazyPut(() => FavoritesController(Get.find(), Get.find()));
  }
}