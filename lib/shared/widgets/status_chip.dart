import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const StatusChip({super.key, required this.text, required this.color});

  factory StatusChip.fromStatus(String status) {
    return StatusChip(text: status, color: colorFor(status));
  }

  static Color colorFor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'resolved':
      case 'available':
      case 'confirmed':
      case 'active':
        return AppColors.success;
      case 'pending':
      case 'in progress':
      case 'inprogress':
        return AppColors.warning;
      case 'due':
      case 'failed':
      case 'open':
      case 'cancelled':
      case 'occupied':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.xs + 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        text,
        style: AppTextStyles.extraSmallSemiBold
            .copyWith(color: AppColors.white),
      ),
    );
  }
}