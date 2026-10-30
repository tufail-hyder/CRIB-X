import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class StudentDialogs {
  StudentDialogs._();

  static Future<bool> confirmLogout() async {
    final ok = await Get.dialog<bool>(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.all(AppSizes.xl),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Logout Confirmation',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionInnerTitle),
              AppSizes.hSm,
              Text('Are you sure you want to logout?',
                  textAlign: TextAlign.center, style: AppTextStyles.body),
              AppSizes.hLg,
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Confirm',
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                  AppSizes.wMd,
                  Expanded(
                    child: PrimaryButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return ok == true;
  }

  static Future<void> success({
    String title = 'Successful',
    required String message,
  }) {
    return Get.dialog(
      _SuccessDialog(title: title, message: message),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  const _SuccessDialog({required this.title, required this.message});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.all(AppSizes.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFFA855F7)],
              ).createShader(rect),
              child: const Icon(Icons.verified_rounded,
                  size: 96, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(widget.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionInnerTitle),
            const SizedBox(height: 4),
            Text(widget.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.smallRegular
                    .copyWith(color: AppColors.gray600)),
          ],
        ),
      ),
    );
  }
}