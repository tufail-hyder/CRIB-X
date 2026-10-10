import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../data/repositories/student_repository.dart';

class RoomsController extends GetxController {
  final RoomRepository _repo;
  final StudentRepository _studentRepo;
  final AuthRepository _auth;
  RoomsController(this._repo, this._studentRepo, this._auth);

  static const seaterOptions = [1, 2, 3, 4, 5, 6];

  final rooms = <RoomModel>[].obs;
  final students = <StudentModel>[].obs; // sirf pending payments count ke liye
  final seaterFilter = RxnInt(); // null = All
  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<RoomModel>>? _sub;
  StreamSubscription<List<StudentModel>>? _studentSub;

  @override
  void onReady() {
    super.onReady();
    listen();
  }

  void listen() {
    final uid = _auth.currentUid ?? '';
    isLoading.value = true;
    errorMessage.value = null;

    _sub?.cancel();
    _sub = _repo.watchRooms(uid).listen(
          (list) {
        rooms.assignAll(list);
        isLoading.value = false;
      },
      onError: (e, s) {
        errorMessage.value = ExceptionHandler.message(e, s);
        isLoading.value = false;
      },
    );

    _studentSub?.cancel();
    _studentSub = _studentRepo
        .watchStudents(uid)
        .listen(students.assignAll, onError: (_) {});
  }

  List<RoomModel> get filtered => seaterFilter.value == null
      ? rooms
      : rooms.where((r) => r.seater == seaterFilter.value).toList();

  // ---- Stats ----
  int get totalRooms => rooms.length;
  int get occupiedBeds => rooms.fold(0, (sum, r) => sum + r.occupiedBeds);
  int get availableBeds => rooms.fold(0, (sum, r) => sum + r.availableBeds);

  /// Asli count: rehne wale students jinhone is mahine ki poori fees nahi di
  int get pendingPayments => students
      .where((s) => s.isActive && s.paymentStatus != PaymentStatus.paid)
      .length;

  void openAdd() => Get.toNamed(AppRoutes.roomForm);

  void openEdit(RoomModel room) =>
      Get.toNamed(AppRoutes.roomForm, arguments: room);

  @override
  void onClose() {
    _sub?.cancel();
    _studentSub?.cancel();
    super.onClose();
  }
}