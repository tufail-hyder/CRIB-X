import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/complaint_model.dart';
import 'complaint_bridge.dart';
import 'complaints_action_menu.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onTap;
  final ValueChanged<ComplaintAction> onAction;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = complaint;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(c.shortId,
                      style: AppTextStyles.smallRegular
                          .copyWith(color: AppColors.gray600)),
                  const SizedBox(width: 8),
                  CategoryChip(category: c.category),
                  const Spacer(),
                  PriorityBadge(priority: c.priority),
                  const SizedBox(width: 6),
                  Builder(
                    builder: (ctx) => InkResponse(
                      onTap: () =>
                          ComplaintActionsMenu.show(ctx, onSelected: onAction),
                      radius: 20,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.more_horiz, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(c.title,
                  style: AppTextStyles.oneLinerSemiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(c.description,
                  style: AppTextStyles.smallRegular
                      .copyWith(color: AppColors.gray600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${c.studentName} · Room ${c.roomNumber}',
                      style: AppTextStyles.smallRegular,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(dateText(c.createdAt),
                      style: AppTextStyles.smallRegular
                          .copyWith(color: AppColors.gray600)),
                ],
              ),
              const SizedBox(height: 8),
              ComplaintStatusChip(status: c.status),
            ],
          ),
        ),
      ),
    );
  }
}