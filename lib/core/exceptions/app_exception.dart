class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NoInternetException extends AppException {
  const NoInternetException()
      : super('No internet connection. Please check your network.',
      code: 'no-internet');
}