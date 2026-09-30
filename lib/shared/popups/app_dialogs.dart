import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_strings.dart';
import '../../core/theme/app_text_styles.dart';

class AppDialogs {
  AppDialogs._();

  /// true = confirm, false/null = cancel
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = AppStrings.cancel,
    bool isDestructive = false,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(title, style: AppTextStyles.sectionInnerTitle),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText,
                style: AppTextStyles.oneLinerSemiBold
                    .copyWith(color: AppColors.gray600)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText,
                style: AppTextStyles.oneLinerSemiBold.copyWith(
                    color:
                    isDestructive ? AppColors.error : AppColors.primary)),
          ),
        ],
      ),
    );
  }

  static Future<bool?> confirmDelete(String itemName) => confirm(
    title: 'Delete $itemName?',
    message: 'This action cannot be undone.',
    confirmText: AppStrings.delete,
    isDestructive: true,
  );

  static Future<void> info({
    required String title,
    required String message,
  }) {
    return Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(title, style: AppTextStyles.sectionInnerTitle),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.ok,
                style: AppTextStyles.oneLinerSemiBold
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}