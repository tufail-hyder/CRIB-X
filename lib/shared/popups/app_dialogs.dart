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

  static Future<String?> prompt({
    required String title,
    String? hint,
    String confirmText = 'Add',
  }) {
    return Get.dialog<String>(
      _PromptDialog(title: title, hint: hint, confirmText: confirmText),
    );
  }

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

class _PromptDialog extends StatefulWidget {
  final String title;
  final String? hint;
  final String confirmText;
  const _PromptDialog(
      {required this.title, this.hint, required this.confirmText});

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: Text(widget.title, style: AppTextStyles.sectionInnerTitle),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLength: 30,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: widget.hint, counterText: ''),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel,
              style: AppTextStyles.oneLinerSemiBold
                  .copyWith(color: AppColors.gray600)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text),
          child: Text(widget.confirmText,
              style: AppTextStyles.oneLinerSemiBold
                  .copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }
}