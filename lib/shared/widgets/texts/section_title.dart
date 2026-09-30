import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionInnerTitle)),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: AppTextStyles.smallSemiBold
                  .copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}