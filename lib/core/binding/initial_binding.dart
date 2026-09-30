import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(
      AuthRepository(Get.find<AuthService>(), Get.find<FirestoreService>()),
      permanent: true,
    );
  }
}