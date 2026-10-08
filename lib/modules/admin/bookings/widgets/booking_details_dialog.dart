import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/booking_model.dart';
import 'booking_badge.dart';

class BookingDetailsDialog extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailsDialog({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final initial = booking.studentName.isEmpty
        ? '?'
        : booking.studentName[0].toUpperCase();

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
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.gray100,
                  child: Text(initial, style: AppTextStyles.oneLinerSemiBold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(booking.studentName,
                      style: AppTextStyles.sectionInnerTitle,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _row('Phone number', booking.phone),
            _row('Room', booking.roomNumber),
            _row('Bed', booking.bed),
            _row('Check in Date', dateText(booking.checkInDate)),
            _row('Duration', booking.durationText),
            if (booking.createdAt != null)
              _row('Booking Date', dateText(booking.createdAt!)),
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.sm),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Booking Status',
                          style: AppTextStyles.oneLinerRegular)),
                  Expanded(
                    flex: 2,
                    child: BookingBadge(
                        status: booking.status,
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