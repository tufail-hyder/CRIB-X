import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_sizes.dart';
import '../../core/constant/app_strings.dart';
import '../../core/theme/app_text_styles.dart';

class FullScreenLoader {
  FullScreenLoader._();

  static bool _isOpen = false;

  static void show([String text = AppStrings.loading]) {
    if (_isOpen) return;
    _isOpen = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                AppSizes.hLg,
                Text(text, style: AppTextStyles.body),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (!_isOpen) return;
    _isOpen = false;
    if (Get.isDialogOpen ?? false) Get.back();
  }
}