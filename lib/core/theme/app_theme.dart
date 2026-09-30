import 'package:flutter/material.dart';
import '../constant/app_colors.dart';
import '../constant/app_sizes.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    borderSide: BorderSide(color: color),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.sectionTitle,
      iconTheme: const IconThemeData(color: AppColors.dark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray100,
      hintStyle: AppTextStyles.placeholder,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg, vertical: AppSizes.md),
      border: _border(AppColors.inputBorder),
      enabledBorder: _border(AppColors.border),
      focusedBorder: _border(AppColors.primary),
      errorBorder: _border(AppColors.error),
      focusedErrorBorder: _border(AppColors.error),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dark,
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        side: const BorderSide(color: AppColors.dark),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      ),
    ),
  );
}