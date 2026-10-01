import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/amenities_card.dart';
import '../../widgets/hostel_images_card.dart';
import '../controllers/hostel_profile_controller.dart';

class HostelProfileView extends GetView<HostelProfileController> {
  const HostelProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Hostel Profile',
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
                    text: 'Save and change',
                    isLoading: c.isSaving.value,
                    onPressed: c.isLoaded.value ? c.save : null,
                  )),
                ),
                AppSizes.wMd,
                Expanded(
                  child: PrimaryButton(
                    text: 'Cancel',
                    isOutlined: true,
                    onPressed: c.cancel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (!c.isLoaded.value) {
          if (c.isLoading.value) return const _Loading();
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load hostel profile',
            message: c.errorMessage.value,
            actionText: 'Retry',
            onAction: c.load,
          );
        }

        return Form(
          key: c.formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              SectionCard(
                title: 'Hostel Basic Information',
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Hostel',
                      hint: 'Hostel name',
                      controller: c.nameCtrl,
                      validator: (v) => Validators.required(v, 'Hostel name'),
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Hostel Address',
                      hint: 'Street, area',
                      controller: c.addressCtrl,
                      validator: (v) => Validators.required(v, 'Address'),
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'City',
                      hint: 'City',
                      controller: c.cityCtrl,
                      validator: (v) => Validators.required(v, 'City'),
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Monthly Price',
                      hint: 'e.g. 15000',
                      controller: c.priceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (v) =>
                          Validators.positiveNumber(v, 'Monthly price'),
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Contact Number',
                      hint: '03XXXXXXXXX',
                      controller: c.phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Email',
                      hint: 'hostel@gmail.com',
                      controller: c.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                  ],
                ),
              ),
              AppSizes.hLg,
              HostelImagesCard(c: c),
              AppSizes.hLg,
              AmenitiesCard(c: c),
              AppSizes.hLg,
              SectionCard(
                title: 'Description',
                child: CustomTextField(
                  hint: 'Describe your hostel for students',
                  controller: c.descCtrl,
                  maxLines: 5,
                  maxLength: 500,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  validator: (v) =>
                      Validators.minLength(v, 10, 'Description'),
                ),
              ),
              AppSizes.hLg,
            ],
          ),
        );
      }),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: const [
        ShimmerLoader(height: 420, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 180, radius: AppSizes.radiusLg),
      ],
    );
  }
}