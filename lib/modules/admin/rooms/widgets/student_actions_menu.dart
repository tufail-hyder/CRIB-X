import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';

enum StudentAction { viewProfile, edit, changeRoom, paymentHistory, remove }

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
      Rect.fromLTWH(topLeft.dx, topLeft.dy + box.size.height, box.size.width, 0),
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
        _item(StudentAction.edit, Icons.edit, 'Edit Student Details'),
        _item(StudentAction.changeRoom, Icons.swap_horiz_rounded,
            'Change Room / Bed'),
        _item(StudentAction.paymentHistory, Icons.account_balance_wallet,
            'View Payment History'),
        _item(StudentAction.remove, Icons.delete_outline, 'Remove Student',
            destructive: true),
      ],
    );

    if (result != null) onSelected(result);
  }

  static PopupMenuItem<StudentAction> _item(
      StudentAction value,
      IconData icon,
      String text, {
        bool destructive = false,
      }) {
    final color = destructive ? AppColors.error : Colors.black;
    return PopupMenuItem<StudentAction>(
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