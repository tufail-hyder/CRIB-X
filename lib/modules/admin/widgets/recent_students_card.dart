import 'package:flutter/material.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/dashboard_stats_model.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/network_image.dart';

class RecentStudentsCard extends StatelessWidget {
  final List<StudentPaymentItem> students;
  const RecentStudentsCard({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Students', style: AppTextStyles.sectionInnerTitle),
          AppSizes.hLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Student', style: AppTextStyles.label),
              Text('Payments', style: AppTextStyles.label),
            ],
          ),
          AppSizes.hSm,
          if (students.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: Text('No students yet', style: AppTextStyles.body),
            )
          else
            for (final s in students)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                child: Row(
                  children: [
                    AppNetworkImage(
                      url: s.photoUrl,
                      width: 32,
                      height: 32,
                      radius: 16,
                    ),
                    AppSizes.wMd,
                    Expanded(
                      child: Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.oneLinerRegular,
                      ),
                    ),
                    StatusChip.fromStatus(s.status, width: 72),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}