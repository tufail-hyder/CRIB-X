import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../../rooms/widgets/student_actions_menu.dart';
import '../widgets/student_details_dialog.dart';

class StudentsController extends GetxController {
  final StudentRepository _repo;
  final RoomRepository _roomRepo;
  final AuthRepository _auth;
  StudentsController(this._repo, this._roomRepo, this._auth);

  final students = <StudentModel>[].obs;
  final rooms = <RoomModel>[].obs; // sirf Room Number filter ke liye

  final roomFilter = RxnString(); // roomId
  final paymentFilter = Rxn<PaymentStatus>();
  final stayFilter = Rxn<StayStatus>();

  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<StudentModel>>? _studentSub;
  StreamSubscription<List<RoomModel>>? _roomSub;

  @override
  void onReady() {
    super.onReady();
    listen();
  }

  void listen() {
    final uid = _auth.currentUid ?? '';
    isLoading.value = true;
    errorMessage.value = null;

    _studentSub?.cancel();
    _studentSub = _repo.watchStudents(uid).listen(
          (list) {
        students.assignAll(list);
        isLoading.value = false;
      },
      onError: (e, s) {
        errorMessage.value = ExceptionHandler.message(e, s);
        isLoading.value = false;
      },
    );

    _roomSub?.cancel();
    _roomSub = _roomRepo.watchRooms(uid).listen(rooms.assignAll, onError: (_) {});
  }

  List<StudentModel> get filtered => students.where((s) {
    if (roomFilter.value != null && s.roomId != roomFilter.value) {
      return false;
    }
    if (paymentFilter.value != null &&
        s.paymentStatus != paymentFilter.value) {
      return false;
    }
    if (stayFilter.value != null && s.stayStatus != stayFilter.value) {
      return false;
    }
    return true;
  }).toList();

  // ---- Stats ----
  int get totalStudents => students.length;
  int get activeResidents => students.where((s) => s.isActive).length;
  int get pendingPayments => students
      .where((s) => s.isActive && s.paymentStatus != PaymentStatus.paid)
      .length;
  int get newCheckIns {
    final now = DateTime.now();
    return students
        .where((s) =>
    s.isActive &&
        s.checkInDate.year == now.year &&
        s.checkInDate.month == now.month)
        .length;
  }

  void openAdd() => Get.toNamed(AppRoutes.studentForm);

  Future<void> onAction(StudentModel student, StudentAction action) async {
    switch (action) {
      case StudentAction.viewProfile:
        Get.dialog(StudentDetailsDialog(student: student));
        break;

      case StudentAction.updateStatus:
        if (!student.isActive) {
          AppSnackbar.info('${student.name} has already left.');
          return;
        }
        Get.toNamed(AppRoutes.paymentForm, arguments: student);
        break;

      case StudentAction.paymentHistory:
        AppSnackbar.info('Payment history will be available soon.');
        break;

      case StudentAction.markResolved:
        await _checkOut(student);
        break;
    }
  }

  Future<void> _checkOut(StudentModel s) async {
    if (!s.isActive) {
      AppSnackbar.info('${s.name} has already left.');
      return;
    }

    final key = StudentModel.monthKey(DateTime.now());
    final remaining = s.remainingFor(key);
    final dueNote = remaining > 0
        ? '\n\nNote: ${remaining.toStringAsFixed(0)} is still unpaid for this month.'
        : '';

    final ok = await AppDialogs.confirm(
      title: 'Mark as resolved?',
      message:
      '${s.name} will be checked out and bed ${s.bed} in Room ${s.roomNumber} will be freed.$dueNote',
      confirmText: 'Confirm',
    );
    if (ok != true) return;

    try {
      await NetworkManager.instance.ensureConnected();
      await _repo.checkOut(s);
      AppSnackbar.success('${s.name} checked out');
    } catch (e, st) {
      AppSnackbar.error(ExceptionHandler.message(e, st));
    }
  }

  @override
  void onClose() {
    _studentSub?.cancel();
    _roomSub?.cancel();
    super.onClose();
  }
}