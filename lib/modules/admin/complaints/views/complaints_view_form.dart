import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/complaint_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/complaints_form_contoller.dart';

class ComplaintFormView extends GetView<ComplaintFormController> {
  const ComplaintFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Create Complaint',
      bottomBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => PrimaryButton(
                    text: 'Create Complaint',
                    isLoading: c.isSaving.value,
                    onPressed: c.save,
                  )),
                ),
                AppSizes.wMd,
                Expanded(
                  child: PrimaryButton(
                    text: 'Cancel',
                    isOutlined: true,
                    onPressed: Get.back,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: c.formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            SectionCard(
              title: 'Complaint Details',
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.students.isEmpty) {
                  return Text(
                    'No active students yet. Add a student first.',
                    style: AppTextStyles.body,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student', style: AppTextStyles.label),
                    AppSizes.hSm,
                    DropdownButtonFormField<String>(
                      value: c.selectedStudentId.value,
                      isExpanded: true,
                      hint: const Text('Select student'),
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: c.students
                          .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.name} · Room ${s.roomNumber}',
                            overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (v) => c.selectedStudentId.value = v,
                      validator: (v) => v == null ? 'Select a student' : null,
                    ),
                    AppSizes.hMd,
                    Text('Issue Type', style: AppTextStyles.label),
                    AppSizes.hSm,
                    DropdownButtonFormField<ComplaintCategory>(
                      value: c.category.value,
                      isExpanded: true,
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: ComplaintCategory.values
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.label)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) c.category.value = v;
                      },
                    ),
                    AppSizes.hMd,
                    Text('Priority', style: AppTextStyles.label),
                    AppSizes.hSm,
                    DropdownButtonFormField<ComplaintPriority>(
                      value: c.priority.value,
                      isExpanded: true,
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: ComplaintPriority.values
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.label)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) c.priority.value = v;
                      },
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Title',
                      hint: 'e.g. Bathroom pipe repair',
                      controller: c.titleCtrl,
                      maxLength: 60,
                      validator: (v) => Validators.required(v, 'Title'),
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Description',
                      hint: 'Describe the problem',
                      controller: c.descCtrl,
                      maxLines: 4,
                      maxLength: 400,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      validator: (v) =>
                          Validators.minLength(v, 10, 'Description'),
                    ),
                  ],
                );
              }),
            ),
            AppSizes.hLg,
          ],
        ),
      ),
    );
  }
}