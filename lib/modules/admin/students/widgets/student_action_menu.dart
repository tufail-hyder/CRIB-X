import 'package:flutter/material.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';

enum StudentAction { viewProfile, updateStatus, paymentHistory, markResolved }

class StudentActionsMenu {
  StudentActionsMenu._();

  static Future<void> show(
      BuildContext context, {
        required ValueChanged<StudentAction> onSelected,
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
          0),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<StudentAction>(
      context: context,
      position: position,
      color: AppColors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      items: [
        _item(StudentAction.viewProfile, Icons.person, 'View Student Profile'),
        _item(StudentAction.updateStatus, Icons.info, 'Update Status'),
        _item(StudentAction.paymentHistory, Icons.account_balance_wallet,
            'View Payment History'),
        _item(StudentAction.markResolved, Icons.delete_outline,
            'Mark as Resolve'),
      ],
    );

    if (result != null) onSelected(result);
  }

  static PopupMenuItem<StudentAction> _item(
      StudentAction value, IconData icon, String text) {
    return PopupMenuItem<StudentAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.oneLinerRegular)),
        ],
      ),
    );
  }
}