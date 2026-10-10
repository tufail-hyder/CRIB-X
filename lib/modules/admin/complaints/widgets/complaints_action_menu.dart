import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';

enum ComplaintAction { viewDetails, updateStatus, markResolved }

class ComplaintActionsMenu {
  ComplaintActionsMenu._();

  static Future<void> show(
      BuildContext context, {
        required ValueChanged<ComplaintAction> onSelected,
      }) async {
    final box = context.findRenderObject() as RenderBox;
    final overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(topLeft.dx, topLeft.dy + box.size.height, 0, 0),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<ComplaintAction>(
      context: context,
      position: position,
      color: AppColors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      items: [
        _item(ComplaintAction.viewDetails, Icons.person, 'View Complaint'),
        _item(ComplaintAction.updateStatus, Icons.info, 'Update Status'),
        _item(ComplaintAction.markResolved, Icons.check_circle_outline,
            'Mark as Resolved'),
      ],
    );

    if (result != null) onSelected(result);
  }

  static PopupMenuItem<ComplaintAction> _item(
      ComplaintAction value, IconData icon, String text) {
    return PopupMenuItem<ComplaintAction>(
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