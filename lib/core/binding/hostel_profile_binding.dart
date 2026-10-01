import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/hostel_repository.dart';
import '../../modules/admin/hostel_profile/controllers/hostel_profile_controller.dart';

class HostelProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HostelProfileController(
      Get.find<HostelRepository>(),
      Get.find<AuthRepository>(),
    ));
  }
}