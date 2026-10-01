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

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await NetworkManager.instance.ensureConnected();
      stats.value = await _repo.getStats(_auth.currentUid ?? '');
    } catch (e, s) {
      final msg = ExceptionHandler.message(e, s);
      if (stats.value != null) {
        AppSnackbar.error(msg);
      } else {
        errorMessage.value = msg;
      }
    } finally {
      isLoading.value = false;
    }
  }
}