import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/student_model.dart';
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

                final months = c.monthOptions;
                final monthValue = months
                    .any((m) => StudentModel.monthKey(m) == c.forMonth.value)
                    ? c.forMonth.value
                    : null;

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
                    if (c.selectedStudent != null) ...[
                      AppSizes.hMd,
                      _Summary(
                        fee: c.fee,
                        paid: c.paidSoFar,
                        remaining: c.remaining,
                      ),
                    ],
                    AppSizes.hMd,
                    Text('Fees for month', style: AppTextStyles.label),
                    AppSizes.hSm,
                    DropdownButtonFormField<String>(
                      key: ValueKey('m-${c.selectedStudentId.value}'),
                      value: monthValue,
                      isExpanded: true,
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: months
                          .map((m) => DropdownMenuItem(
                        value: StudentModel.monthKey(m),
                        child: Text(monthText(m)),
                      ))
                          .toList(),
                      onChanged: c.onMonthChanged,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Amount (partial payment allowed)',
                      hint: 'e.g. 5000',
                      controller: c.amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: c.validateAmount,
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
                      hint: 'e.g. Second installment',
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

class _Summary extends StatelessWidget {
  final double fee;
  final double paid;
  final double remaining;
  const _Summary(
      {required this.fee, required this.paid, required this.remaining});

  @override
  Widget build(BuildContext context) {
    Widget row(String l, String v, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(l, style: AppTextStyles.smallRegular)),
          Text(v,
              style: bold
                  ? AppTextStyles.smallSemiBold
                  : AppTextStyles.smallRegular),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          row('Monthly fee', fee > 0 ? Formatters.currency(fee) : 'Not set'),
          row('Paid for this month', Formatters.currency(paid)),
          if (fee > 0) row('Remaining', Formatters.currency(remaining), bold: true),
        ],
      ),
    );
  }
}