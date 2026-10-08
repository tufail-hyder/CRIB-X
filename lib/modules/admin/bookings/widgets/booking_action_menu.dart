import 'package:flutter/material.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';

enum BookingAction { viewDetails, approve, reject }

class BookingActionsMenu {
  BookingActionsMenu._();

  static Future<void> show(
      BuildContext context, {
        required ValueChanged<BookingAction> onSelected,
      }) async {
    final box = context.findRenderObject() as RenderBox;
    final overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(
        topLeft.dx + box.size.width * 0.35,
        topLeft.dy + box.size.height,
        0,
        0,
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<BookingAction>(
      context: context,
      position: position,
      color: AppColors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      items: [
        _item(BookingAction.viewDetails, Icons.person, 'View Booking Details',
              Colors.black),
        _item(BookingAction.approve, Icons.check_circle_outline,
            'Approve Booking', AppColors.success),
        _item(BookingAction.reject, Icons.cancel_outlined, 'Reject Booking',
            AppColors.error),
      ],
    );

    if (result != null) onSelected(result);
  }

  static PopupMenuItem<BookingAction> _item(
      BookingAction value, IconData icon, String text, Color color) {
    return PopupMenuItem<BookingAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: AppTextStyles.oneLinerRegular.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}