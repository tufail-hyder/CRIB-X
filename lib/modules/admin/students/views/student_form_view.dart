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
import '../controllers/student_form_controller.dart';

class StudentFormView extends GetView<StudentFormController> {
  const StudentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Add New Student',
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
                    text: 'Add Student',
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
              title: 'Student Information',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Student name',
                    controller: c.nameCtrl,
                    validator: (v) => Validators.required(v, 'Name'),
                  ),
                  AppSizes.hMd,
                  CustomTextField(
                    label: 'Phone Number',
                    hint: '03XXXXXXXXX',
                    controller: c.phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  AppSizes.hMd,
                  CustomTextField(
                    label: 'CNIC (optional)',
                    hint: 'XXXXX-XXXXXXX-X',
                    controller: c.cnicCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            AppSizes.hLg,
            SectionCard(
              title: 'Room & Payment',
              child: Obx(() {
                if (c.isLoadingRooms.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.rooms.isEmpty) {
                  return Text(
                    'No free beds available. Add a room or free a bed first.',
                    style: AppTextStyles.body,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room', style: AppTextStyles.label),
                    AppSizes.hSm,
                    DropdownButtonFormField<String>(
                      value: c.selectedRoomId.value,
                      isExpanded: true,
                      hint: const Text('Select room'),
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: c.rooms
                          .map((r) => DropdownMenuItem(
                        value: r.id,
                        child: Text(
                            'Room ${r.roomNumber} · ${r.availableBeds} free'),
                      ))
                          .toList(),
                      onChanged: c.onRoomChanged,
                      validator: (v) => v == null ? 'Select a room' : null,
                    ),
                    AppSizes.hMd,
                    Text('Bed', style: AppTextStyles.label),
                    AppSizes.hSm,
                    DropdownButtonFormField<String>(
                      key: ValueKey(c.selectedRoomId.value),
                      value: c.selectedBed.value,
                      isExpanded: true,
                      hint: const Text('Select bed'),
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: c.freeBeds
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => c.selectedBed.value = v,
                      validator: (v) => v == null ? 'Select a bed' : null,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Check in Date',
                      controller: c.dateCtrl,
                      readOnly: true,
                      onTap: c.pickDate,
                      suffix: const Icon(Icons.calendar_today_outlined,
                          size: AppSizes.iconMd, color: AppColors.inputIcon),
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Monthly Fee',
                      hint: 'e.g. 15000',
                      controller: c.feeCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: c.validateFee,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Amount Paid Now (optional)',
                      hint: '0',
                      controller: c.paidCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      validator: c.validatePaid,
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