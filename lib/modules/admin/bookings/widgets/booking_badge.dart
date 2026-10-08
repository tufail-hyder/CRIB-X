import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/booking_model.dart';

class BookingBadge extends StatelessWidget {
  final BookingStatus status;
  final double? width;
  final double height;
  const BookingBadge(
      {super.key, required this.status, this.width = 76, this.height = 30});

  Color get _color {
    switch (status) {
      case BookingStatus.approved:
        return AppColors.success;
      case BookingStatus.rejected:
        return AppColors.error;
      case BookingStatus.pending:
        return AppColors.warning;
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
      child: Text(status.label,
          style: AppTextStyles.smallSemiBold.copyWith(color: AppColors.white)),
    );
  }
}