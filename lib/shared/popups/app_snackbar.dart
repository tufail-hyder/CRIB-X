import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';

class AppSnackbar {
  AppSnackbar._();

  static void _show(String title, String message, Color color, IconData icon) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      titleText: Text(title,
          style: AppTextStyles.oneLinerSemiBold
              .copyWith(color: AppColors.white)),
      messageText: Text(message,
          style: AppTextStyles.smallRegular.copyWith(color: AppColors.white)),
      icon: Icon(icon, color: AppColors.white),
      backgroundColor: color,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppSizes.lg),
      borderRadius: AppSizes.radiusMd,
      duration: const Duration(seconds: 3),
    );
  }

  static void success(String message, {String title = 'Success'}) =>
      _show(title, message, AppColors.success, Icons.check_circle_outline);

  static void error(String message, {String title = 'Error'}) =>
      _show(title, message, AppColors.error, Icons.error_outline);

  static void warning(String message, {String title = 'Warning'}) =>
      _show(title, message, AppColors.warning, Icons.warning_amber_rounded);

  static void info(String message, {String title = 'Info'}) =>
      _show(title, message, AppColors.info, Icons.info_outline);
}