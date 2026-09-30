import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constant/app_strings.dart';
import '../utils/logger.dart';
import 'app_exception.dart';

class ExceptionHandler {
  ExceptionHandler._();

  static String message(Object error, [StackTrace? stack]) {
    AppLogger.e('Exception caught', error, stack);

    if (error is AppException) return error.message;
    if (error is FirebaseAuthException) return _auth(error.code);
    if (error is FirebaseException) return _firebase(error.code);
    if (error is DioException) return _dio(error);
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    if (error is FormatException) return 'Invalid data received.';
    return AppStrings.somethingWrong;
  }

  static String _auth(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'requires-recent-login':
        return 'Please log in again to continue.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static String _firebase(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to do this.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This record already exists.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Service is unavailable. Please try again.';
      case 'unauthenticated':
        return 'Please log in to continue.';
      default:
        return AppStrings.somethingWrong;
    }
  }

  static String _dio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode ?? ''}). Try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return AppStrings.somethingWrong;
    }
  }
}