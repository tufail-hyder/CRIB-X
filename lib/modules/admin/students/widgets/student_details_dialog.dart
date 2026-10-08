import 'package:crib_x/modules/admin/students/widgets/payment_bridge.dart';
import 'package:flutter/material.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/student_model.dart';
import '../../../../shared/widgets/network_image.dart';

class StudentDetailsDialog extends StatelessWidget {
  final StudentModel student;
  const StudentDetailsDialog({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.all(AppSizes.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AppNetworkImage(
                    url: student.photoUrl, width: 36, height: 36, radius: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(student.name,
                      style: AppTextStyles.sectionInnerTitle,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _row('Phone number', student.phone),
            _row('Room', student.roomNumber),
            _row('Bed', student.bed),
            _row('Check in Date', dateText(student.checkInDate)),
            if (!student.isActive && student.checkOutDate != null)
              _row('Check out Date', dateText(student.checkOutDate!)),
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.sm),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Payments Status',
                          style: AppTextStyles.oneLinerRegular)),
                  Expanded(
                    flex: 2,
                    child: PaymentBadge(
                        status: student.paymentStatus,
                        width: double.infinity,
                        height: 36),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.oneLinerRegular)),
        Expanded(
          flex: 2,
          child: Text(value, style: AppTextStyles.oneLinerRegular),
        ),
      ],
    ),
  );
}