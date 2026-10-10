import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/complaint_model.dart';

/// Dialog ka result
class StatusUpdate {
  final ComplaintStatus status;
  final String? response;
  const StatusUpdate(this.status, this.response);
}

class UpdateComplaintStatusDialog extends StatefulWidget {
  final ComplaintModel complaint;
  const UpdateComplaintStatusDialog({super.key, required this.complaint});

  @override
  State<UpdateComplaintStatusDialog> createState() =>
      _UpdateComplaintStatusDialogState();
}

class _UpdateComplaintStatusDialogState
    extends State<UpdateComplaintStatusDialog> {
  late ComplaintStatus _status = widget.complaint.status;
  final _response = TextEditingController();

  @override
  void dispose() {
    _response.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: Text('Update status', style: AppTextStyles.sectionInnerTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...ComplaintStatus.values.map((s) => InkWell(
              onTap: () => setState(() => _status = s),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _status == s
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 20,
                      color: _status == s
                          ? AppColors.primary
                          : AppColors.gray400,
                    ),
                    const SizedBox(width: 10),
                    Text(s.label, style: AppTextStyles.oneLinerRegular),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 8),
            TextField(
              controller: _response,
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Response to student (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel',
              style: AppTextStyles.oneLinerSemiBold
                  .copyWith(color: AppColors.gray600)),
        ),
        TextButton(
          onPressed: () => Get.back(result: StatusUpdate(_status, _response.text)),
          child: Text('Update',
              style: AppTextStyles.oneLinerSemiBold
                  .copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }
}