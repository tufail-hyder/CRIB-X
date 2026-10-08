import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/student_model.dart';

class PaymentBadge extends StatelessWidget {
  final PaymentStatus status;
  final double? width;
  final double height;
  const PaymentBadge(
      {super.key, required this.status, this.width = 70, this.height = 30});

  Color get _color {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.due:
        return AppColors.error;
      case PaymentStatus.pending:
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