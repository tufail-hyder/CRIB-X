class Validators {
  Validators._();

  static String? required(String? v, [String field = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Use letters and numbers';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (v) {
      if (v == null || v.isEmpty) return 'Confirm your password';
      if (v != original()) return 'Passwords do not match';
      return null;
    };
  }

  /// Pakistan mobile: 03XXXXXXXXX ya +923XXXXXXXXX
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final cleaned = v.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^(03\d{9}|\+923\d{9})$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? minLength(String? v, int min, [String field = 'This field']) {
    if (v == null || v.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }

  static String? number(String? v, [String field = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
    return null;
  }

  static String? positiveNumber(String? v, [String field = 'This field']) {
    final err = number(v, field);
    if (err != null) return err;
    if (double.parse(v!.trim()) <= 0) return '$field must be greater than 0';
    return null;
  }

  static String? cnic(String? v) {
    if (v == null || v.trim().isEmpty) return 'CNIC is required';
    if (!RegExp(r'^\d{13}$').hasMatch(v.replaceAll('-', '').trim())) {
      return 'Enter a valid 13-digit CNIC';
    }
    return null;
  }
}