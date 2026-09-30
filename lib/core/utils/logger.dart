import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(String msg) {
    if (kDebugMode) debugPrint('[DEBUG] $msg');
  }

  static void e(String msg, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $msg ${error ?? ''}');
      if (stack != null) debugPrint(stack.toString());
    }
  }
}