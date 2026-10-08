import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/room_form_controller.dart';
import '../controllers/rooms_controller.dart';

class RoomFormView extends GetView<RoomFormController> {
  const RoomFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: c.isEdit ? 'Edit Room' : 'Add Room',
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
                    text: c.isEdit ? 'Save changes' : 'Add Room',
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
              title: 'Room Information',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Room Number',
                    hint: 'e.g. 101',
                    controller: c.numberCtrl,
                    validator: (v) => Validators.required(v, 'Room number'),
                  ),
                  AppSizes.hMd,
                  Text('Room Type', style: AppTextStyles.label),
                  AppSizes.hSm,
                  Obx(() => DropdownButtonFormField<int>(
                    value: c.seater.value,
                    isExpanded: true,
                    style: AppTextStyles.oneLinerRegular,
                    items: RoomsController.seaterOptions
                        .map((s) => DropdownMenuItem(
                        value: s, child: Text('$s seater')))
                        .toList(),
                    onChanged: c.onSeaterChanged,
                  )),
                  AppSizes.hMd,
                  CustomTextField(
                    label: 'Total Beds',
                    hint: 'e.g. 2',
                    controller: c.bedsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: c.validateBeds,
                  ),
                  AppSizes.hMd,
                  CustomTextField(
                    label: 'Monthly Price (per bed)',
                    hint: 'e.g. 15000',
                    controller: c.priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    validator: (v) =>
                        Validators.positiveNumber(v, 'Monthly price'),
                  ),
                  AppSizes.hSm,
                  Obx(() => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: Text('Mark as reserved',
                        style: AppTextStyles.oneLinerRegular),
                    value: c.isReserved.value,
                    onChanged: (v) => c.isReserved.value = v,
                  )),
                ],
              ),
            ),
            if (c.isEdit) ...[
              AppSizes.hLg,
              OutlinedButton.icon(
                onPressed: c.delete,
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                label: Text('Delete Room',
                    style: AppTextStyles.oneLinerSemiBold
                        .copyWith(color: AppColors.error)),
              ),
            ],
            AppSizes.hLg,
          ],
        ),
      ),
    );
  }
}