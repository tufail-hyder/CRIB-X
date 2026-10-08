import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/payment_form_controller.dart';

class PaymentFormView extends GetView<PaymentFormController> {
  const PaymentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Record Payment',
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
                    text: 'Save Payment',
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
              title: 'Payment Details',
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
                        child: Text(
                          '${s.name} · Room ${s.roomNumber}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                          .toList(),
                      onChanged: c.onStudentChanged,
                      validator: (v) => v == null ? 'Select a student' : null,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Amount',
                      hint: 'e.g. 15000',
                      controller: c.amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => Validators.positiveNumber(v, 'Amount'),
                    ),
                    AppSizes.hMd,
                    Text('Fees for month', style: AppTextStyles.label),
                    AppSizes.hSm,
                    DropdownButtonFormField<String>(
                      value: c.forMonth.value,
                      isExpanded: true,
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: c.monthOptions
                          .map((m) => DropdownMenuItem(
                        value: PaymentModel.monthKey(m),
                        child: Text(c.monthLabel(m)),
                      ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) c.forMonth.value = v;
                      },
                    ),
                    AppSizes.hMd,
                    Text('Payment Method', style: AppTextStyles.label),
                    AppSizes.hSm,
                    DropdownButtonFormField<PaymentMethod>(
                      value: c.method.value,
                      isExpanded: true,
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: PaymentMethod.values
                          .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m.label)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) c.method.value = v;
                      },
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Note (optional)',
                      hint: 'e.g. Advance for next month',
                      controller: c.noteCtrl,
                      textInputAction: TextInputAction.done,
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