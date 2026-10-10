import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/complaint_model.dart';
import 'complaint_bridge.dart';

class ComplaintDetailsDialog extends StatelessWidget {
  final ComplaintModel complaint;
  const ComplaintDetailsDialog({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final c = complaint;

    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.all(AppSizes.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(c.title, style: AppTextStyles.sectionInnerTitle),
                ),
                Text(c.shortId,
                    style: AppTextStyles.smallRegular
                        .copyWith(color: AppColors.gray600)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _row('Student', Text(c.studentName, style: AppTextStyles.oneLinerRegular)),
            _row('Room', Text(c.roomNumber, style: AppTextStyles.oneLinerRegular)),
            _row('Issue Type', Align(alignment: Alignment.centerLeft, child: CategoryChip(category: c.category))),
            _row('Priority', Align(alignment: Alignment.centerLeft, child: PriorityBadge(priority: c.priority))),
            _row('Status', Align(alignment: Alignment.centerLeft, child: ComplaintStatusChip(status: c.status))),
            _row('Date', Text(dateText(c.createdAt), style: AppTextStyles.oneLinerRegular)),
            if (c.resolvedAt != null)
              _row('Resolved on',
                  Text(dateText(c.resolvedAt!), style: AppTextStyles.oneLinerRegular)),
            const SizedBox(height: AppSizes.sm),
            Text('Description', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(c.description, style: AppTextStyles.body),
            if (c.adminResponse != null && c.adminResponse!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.md),
              Text('Admin response', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(c.adminResponse!, style: AppTextStyles.body),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, Widget value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.oneLinerRegular)),
        Expanded(flex: 2, child: value),
      ],
    ),
  );
}