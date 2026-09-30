import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../exceptions/app_exception.dart';

class NetworkManager extends GetxService {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  final RxBool isOnline = true.obs;

  Future<NetworkManager> init() async {
    _setStatus(await _connectivity.checkConnectivity());
    _sub = _connectivity.onConnectivityChanged.listen(_setStatus);
    return this;
  }

  void _setStatus(List<ConnectivityResult> results) {
    isOnline.value = results.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> ensureConnected() async {
    if (!await hasConnection()) throw const NoInternetException();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}