import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    this.icon = Icons.inbox_outlined,
    this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.gray400),
            AppSizes.hLg,
            Text(title, style: AppTextStyles.sectionInnerTitle),
            if (message != null) ...[
              AppSizes.hSm,
              Text(message!,
                  textAlign: TextAlign.center, style: AppTextStyles.body),
            ],
            if (actionText != null) ...[
              AppSizes.hXl,
              SizedBox(
                width: 180,
                child: ElevatedButton(
                    onPressed: onAction, child: Text(actionText!)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}