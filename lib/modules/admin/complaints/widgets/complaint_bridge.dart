import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/complaint_model.dart';

class PriorityBadge extends StatelessWidget {
  final ComplaintPriority priority;
  final double? width;
  final double height;
  const PriorityBadge(
      {super.key, required this.priority, this.width = 64, this.height = 28});

  Color get _color {
    switch (priority) {
      case ComplaintPriority.low:
        return AppColors.success;
      case ComplaintPriority.medium:
        return AppColors.warning;
      case ComplaintPriority.high:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(priority.label,
          style: AppTextStyles.smallSemiBold.copyWith(color: AppColors.white)),
    );
  }
}

/// Issue Type chip (Maintenance, WiFi, Food, Cleaning...)
class CategoryChip extends StatelessWidget {
  final ComplaintCategory category;
  const CategoryChip({super.key, required this.category});

  (Color, Color) get _colors {
    switch (category) {
      case ComplaintCategory.maintenance:
        return (const Color(0xFFFDE2E2), const Color(0xFFB91C1C));
      case ComplaintCategory.wifi:
        return (const Color(0xFFF3E8FF), const Color(0xFF7E22CE));
      case ComplaintCategory.food:
        return (const Color(0xFFDCFCE7), const Color(0xFF15803D));
      case ComplaintCategory.cleanliness:
        return (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8));
      case ComplaintCategory.water:
        return (const Color(0xFFCFFAFE), const Color(0xFF0E7490));
      case ComplaintCategory.electricity:
        return (const Color(0xFFFEF9C3), const Color(0xFFA16207));
      case ComplaintCategory.security:
        return (const Color(0xFFE5E7EB), const Color(0xFF374151));
      case ComplaintCategory.other:
        return (const Color(0xFFF3F4F6), const Color(0xFF4B5563));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(category.label,
          style: AppTextStyles.smallSemiBold.copyWith(color: fg, fontSize: 11)),
    );
  }
}

/// Open / In Progress / Resolved: chhota dot + text
class ComplaintStatusChip extends StatelessWidget {
  final ComplaintStatus status;
  const ComplaintStatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case ComplaintStatus.open:
        return AppColors.error;
      case ComplaintStatus.inProgress:
        return AppColors.warning;
      case ComplaintStatus.resolved:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(status.label,
            style: AppTextStyles.smallRegular.copyWith(color: _color)),
      ],
    );
  }
}