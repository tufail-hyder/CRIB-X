import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/room_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import 'student_actions_menu.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final ValueChanged<StudentAction> onAction;
  const RoomCard({super.key, required this.room, required this.onAction});

  Color get _statusColor {
    switch (room.displayStatus) {
      case RoomStatus.available:
        return AppColors.success;
      case RoomStatus.occupied:
        return AppColors.error;
      case RoomStatus.reserved:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Room ${room.roomNumber}',
                  style: AppTextStyles.sectionInnerTitle),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  room.displayStatus.label,
                  style: AppTextStyles.smallSemiBold
                      .copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('${room.seater} seater', style: AppTextStyles.smallRegular),
          const _Line(),
          Row(
            children: [
              Text('${room.totalBeds} bed',
                  style: AppTextStyles.oneLinerSemiBold),
              const SizedBox(width: 8),
              const Icon(Icons.bed_rounded, size: AppSizes.iconMd),
              const Spacer(),
              Text('${room.occupiedBeds}/${room.totalBeds} occupied',
                  style: AppTextStyles.smallRegular),
            ],
          ),
          const _Line(),
          Text('${Formatters.currency(room.monthlyPrice)}/month',
              style: AppTextStyles.oneLinerSemiBold),
          const _Line(),
          Builder(
            builder: (btnContext) => PrimaryButton(
              text: 'Edit',
              onPressed: () => StudentActionsMenu.show(
                btnContext,
                onSelected: onAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
    child: Divider(height: 1, color: AppColors.border),
  );
}