import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../widgets/student_actions_menu.dart';

class RoomsController extends GetxController {
  final RoomRepository _repo;
  final AuthRepository _auth;
  RoomsController(this._repo, this._auth);

  static const seaterOptions = [1, 2, 3, 4, 5, 6];

  final rooms = <RoomModel>[].obs;
  final seaterFilter = RxnInt(); // null = All
  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<RoomModel>>? _sub;

  @override
  void onReady() {
    super.onReady();
    listen();
  }

  void listen() {
    isLoading.value = true;
    errorMessage.value = null;
    _sub?.cancel();
    _sub = _repo.watchRooms(_auth.currentUid ?? '').listen(
          (list) {
        rooms.assignAll(list);
        isLoading.value = false;
      },
      onError: (e, s) {
        errorMessage.value = ExceptionHandler.message(e, s);
        isLoading.value = false;
      },
    );
  }

  List<RoomModel> get filtered => seaterFilter.value == null
      ? rooms
      : rooms.where((r) => r.seater == seaterFilter.value).toList();

  // ---- Stats ----
  int get totalRooms => rooms.length;
  int get occupiedBeds => rooms.fold(0, (sum, r) => sum + r.occupiedBeds);
  int get availableBeds => rooms.fold(0, (sum, r) => sum + r.availableBeds);

  /// TODO: Payments module banne ke baad real count.
  int get pendingPayments => 0;

  void openAdd() => Get.toNamed(AppRoutes.roomForm);

  Future<void> onAction(RoomModel room, StudentAction action) async {
    switch (action) {
      case StudentAction.edit:
        Get.toNamed(AppRoutes.roomForm, arguments: room);
        break;

      case StudentAction.remove:
        final ok = await AppDialogs.confirm(
          title: 'Remove student?',
          message: 'The student will be removed from Room ${room.roomNumber}.',
          confirmText: 'Remove',
          isDestructive: true,
        );
        if (ok == true) _comingSoon();
        break;

      case StudentAction.viewProfile:
      case StudentAction.changeRoom:
      case StudentAction.paymentHistory:
        _comingSoon();
        break;
    }
  }

  void _comingSoon() =>
      AppSnackbar.info('This will work once the Students module is ready.');

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}