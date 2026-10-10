import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/complaint_repository.dart';
import '../../data/repositories/hostel_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/room_repository.dart'; // <- add
import '../../data/repositories/setting_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/cloudinary_service.dart';
import '../../data/services/firestore_service.dart';
import '../network/network_manager.dart';

class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    await Get.putAsync(() => NetworkManager().init(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(AuthRepository(Get.find<AuthService>(), Get.find<FirestoreService>()), permanent: true,);
    Get.put(CloudinaryService(), permanent: true);
    Get.put(HostelRepository(Get.find<FirestoreService>(), Get.find<CloudinaryService>()), permanent: true,);
    Get.put(RoomRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(StudentRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(BookingRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(PaymentRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(ComplaintRepository(Get.find<FirestoreService>()), permanent: true);
    Get.put(SettingsRepository(Get.find<FirestoreService>(), Get.find<CloudinaryService>()), permanent: true,);
  }
}