import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textHeading,
    double height = 1.4,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  // Typography
  static TextStyle get screenTitle => _base(size: 24, weight: FontWeight.w600);
  static TextStyle get sectionTitle => _base(size: 18, weight: FontWeight.w600);
  static TextStyle get sectionInnerTitle => _base(size: 16, weight: FontWeight.w600);
  static TextStyle get body => _base(size: 14, weight: FontWeight.w400, color: AppColors.textParagraph);
  static TextStyle get oneLinerRegular => _base(size: 14, weight: FontWeight.w400);
  static TextStyle get oneLinerSemiBold => _base(size: 14, weight: FontWeight.w600);
  static TextStyle get smallRegular => _base(size: 12, weight: FontWeight.w400, color: AppColors.textParagraph);
  static TextStyle get smallSemiBold => _base(size: 12, weight: FontWeight.w600);
  static TextStyle get extraSmallSemiBold => _base(size: 10, weight: FontWeight.w600);
  static TextStyle get label => _base(size: 12, weight: FontWeight.w500);
  static TextStyle get placeholder => _base(size: 13, weight: FontWeight.w400, color: AppColors.textPlaceholder);
  static TextStyle get button => _base(size: 14, weight: FontWeight.w600, color: AppColors.white);
}