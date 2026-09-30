import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;

    final child = isLoading
        ? SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: isOutlined ? AppColors.dark : AppColors.white,
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSizes.iconMd),
          AppSizes.wSm,
        ],
        Text(text),
      ],
    );

    return isOutlined
        ? OutlinedButton(
      onPressed: disabled ? null : onPressed,
      child: child,
    )
        : ElevatedButton(
      onPressed: disabled ? null : onPressed,
      child: child,
    );
  }
}