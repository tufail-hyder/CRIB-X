import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base
  static const Color dark = Color(0xFF1F1F1F);
  static const Color white = Color(0xFFFFFFFF);

  // Gray
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Primary (verify with Figma)
  static const Color primary = Color(0xFF7A41F7);
  static const Color primary50 = Color(0xFFF1EBFE);
  static const Color primary100 = Color(0xFFDDCEFD);
  static const Color primary200 = Color(0xFFBB9DFB);
  static const Color primary300 = Color(0xFF4408C4);

  // Status (paid / pending / due)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF97316);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Color themes
  static const Color textHeading = dark;
  static const Color textParagraph = gray600;
  static const Color textLabel = dark;
  static const Color textPlaceholder = gray400;
  static const Color tableHeader = gray900;
  static const Color disabledBg = gray100;
  static const Color border = gray200;
  static const Color inputBorder = gray300;
  static const Color inputIcon = gray500;
  static const Color scaffoldBg = gray100;
}