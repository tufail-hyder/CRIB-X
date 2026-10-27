import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../data/models/dashboard_stats_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repo;
  final AuthRepository _auth;
  DashboardController(this._repo, this._auth);

  final stats = Rxn<DashboardStats>();
  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<DashboardStats>? _sub;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  void _fail(Object e, StackTrace s) {
    final msg = ExceptionHandler.message(e, s);
    if (stats.value != null) {
      AppSnackbar.error(msg); // purana data dikhta rahe
    } else {
      errorMessage.value = msg;
    }
    isLoading.value = false;
  }

  /// Live stream shuru karta hai. Pehla data aate hi Future complete hota hai
  /// (isi liye pull-to-refresh ka spinner sahi waqt par band hota hai).
  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await NetworkManager.instance.ensureConnected();
    } catch (e, s) {
      _fail(e, s);
      return;
    }

    await _sub?.cancel();
    final first = Completer<void>();

    _sub = _repo.watchStats(_auth.currentUid ?? '').listen(
          (s) {
        stats.value = s;
        errorMessage.value = null;
        isLoading.value = false;
        if (!first.isCompleted) first.complete();
      },
      onError: (Object e, StackTrace st) {
        _fail(e, st);
        if (!first.isCompleted) first.complete();
      },
    );

    await first.future;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}