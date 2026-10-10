import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/setting_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/network_image.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/setting_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Settings',
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
                    onPressed: c.isLoading.value ? null : c.save,
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
        if (c.isLoading.value) return const _Loading();

        if (c.errorMessage.value != null) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load settings',
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
              // ---------------- Account ----------------
              SectionCard(
                title: 'Account Setting',
                child: Column(
                  children: [
                    Center(
                      child: Obx(() => c.photoUrl.value == null
                          ? Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: const Icon(Icons.person,
                            size: 56, color: AppColors.gray400),
                      )
                          : AppNetworkImage(
                        url: c.photoUrl.value,
                        width: 120,
                        height: 120,
                        radius: AppSizes.radiusMd,
                      )),
                    ),
                    AppSizes.hSm,
                    Obx(() => SizedBox(
                      width: 150,
                      child: PrimaryButton(
                        text: 'Upload Photo',
                        isLoading: c.isUploadingPhoto.value,
                        onPressed: c.pickPhoto,
                      ),
                    )),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Hostel Name',
                      hint: 'Hostel name',
                      controller: c.hostelNameCtrl,
                      validator: (v) => Validators.required(v, 'Hostel name'),
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
                      label: 'CNIC',
                      hint: 'XXXXX-XXXXXXX-X',
                      controller: c.cnicCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                      ],
                      validator: c.validateCnic,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Phone number',
                      hint: '03XXXXXXXXX',
                      controller: c.phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: c.validatePhone,
                    ),
                  ],
                ),
              ),
              AppSizes.hLg,

              // ---------------- Notifications ----------------
              SectionCard(
                title: 'Notification Setting',
                child: Column(
                  children: [
                    Obx(() => _SwitchRow(
                      label: 'New Booking Alerts',
                      value: c.newBooking.value,
                      onChanged: (v) {
                        c.newBooking.value = v;
                        c.markDirty();
                      },
                    )),
                    Obx(() => _SwitchRow(
                      label: 'Rent Due Reminders',
                      value: c.rentDue.value,
                      onChanged: (v) {
                        c.rentDue.value = v;
                        c.markDirty();
                      },
                    )),
                    Obx(() => _SwitchRow(
                      label: 'Complaint Notification',
                      value: c.complaint.value,
                      onChanged: (v) {
                        c.complaint.value = v;
                        c.markDirty();
                      },
                    )),
                    const _SwitchRow(
                      label: 'Subscription Expiry Alerts',
                      value: true,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
              AppSizes.hLg,

              // ---------------- Preferences ----------------
              SectionCard(
                title: 'Hostel Preferences',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Default Monthly Rent (per bed)',
                      hint: 'e.g. 15000',
                      controller: c.defaultPriceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: c.validateDefaultPrice,
                    ),
                    AppSizes.hMd,
                    Text('Currency', style: AppTextStyles.label),
                    AppSizes.hSm,
                    Obx(() => DropdownButtonFormField<String>(
                      value: c.currency.value,
                      isExpanded: true,
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: const [
                        DropdownMenuItem(
                            value: 'PKR',
                            child: Text('PKR - Pakistani Rupees')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        c.currency.value = v;
                        c.markDirty();
                      },
                    )),
                    AppSizes.hMd,
                    Text('Language', style: AppTextStyles.label),
                    AppSizes.hSm,
                    Obx(() => DropdownButtonFormField<String>(
                      value: c.language.value,
                      isExpanded: true,
                      style: AppTextStyles.oneLinerRegular
                          .copyWith(color: Colors.black),
                      items: const [
                        DropdownMenuItem(
                            value: 'English', child: Text('English')),
                        DropdownMenuItem(
                            value: 'Urdu',
                            enabled: false,
                            child: Text('Urdu (coming soon)')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        c.language.value = v;
                        c.markDirty();
                      },
                    )),
                  ],
                ),
              ),
              AppSizes.hLg,

              // ---------------- Security ----------------
              SectionCard(
                title: 'Security Setting',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leave these empty if you do not want to change your password.',
                      style: AppTextStyles.smallRegular
                          .copyWith(color: AppColors.gray600),
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Current Password',
                      hint: '••••••••',
                      controller: c.currentPassCtrl,
                      isPassword: true,
                      validator: c.validateCurrentPass,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'New Password',
                      hint: '••••••••',
                      controller: c.newPassCtrl,
                      isPassword: true,
                      validator: c.validateNewPass,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: '••••••••',
                      controller: c.confirmPassCtrl,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: c.validateConfirmPass,
                    ),
                  ],
                ),
              ),
              AppSizes.hLg,

              // ---------------- Payment Method ----------------
              _PaymentMethodCard(c: c),
              AppSizes.hLg,

              OutlinedButton.icon(
                onPressed: c.logout,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text('Log out',
                    style: AppTextStyles.oneLinerSemiBold
                        .copyWith(color: AppColors.error)),
              ),
              AppSizes.hLg,
            ],
          ),
        );
      }),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _SwitchRow(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.oneLinerRegular)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Payment Method: header me "+" chahiye, isliye apna card
class _PaymentMethodCard extends StatelessWidget {
  final SettingsController c;
  const _PaymentMethodCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Payment Method',
                    style: AppTextStyles.sectionInnerTitle),
              ),
              IconButton(
                onPressed: c.addAccount,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add payment method',
              ),
            ],
          ),
          Text(
            'Students will see these accounts to send their fees.',
            style:
            AppTextStyles.smallRegular.copyWith(color: AppColors.gray600),
          ),
          AppSizes.hMd,
          Obx(() {
            if (c.accounts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                child: Text('No payment method added yet. Tap + to add one.',
                    style: AppTextStyles.smallRegular),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < c.accounts.length; i++)
                  KeyedSubtree(
                    key: ObjectKey(c.accounts[i]),
                    child: _AccountBlock(c: c, d: c.accounts[i], index: i),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _AccountBlock extends StatelessWidget {
  final SettingsController c;
  final AccountDraft d;
  final int index;
  const _AccountBlock({required this.c, required this.d, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() => _TypeChip(
                label: PaymentAccountType.bank.label,
                selected: d.type.value == PaymentAccountType.bank,
                onTap: () => c.setType(d, PaymentAccountType.bank),
              )),
              const SizedBox(width: 8),
              Obx(() => _TypeChip(
                label: PaymentAccountType.online.label,
                selected: d.type.value == PaymentAccountType.online,
                onTap: () => c.setType(d, PaymentAccountType.online),
              )),
              const Spacer(),
              IconButton(
                onPressed: () => c.removeAccount(d),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: 'Remove',
              ),
            ],
          ),
          AppSizes.hSm,
          Obx(() {
            final isBank = d.type.value == PaymentAccountType.bank;
            return Column(
              children: [
                CustomTextField(
                  label: 'User name (account title)',
                  hint: 'Account holder name',
                  controller: d.titleCtrl,
                  validator: (v) =>
                      c.validateAccountField(d, v, 'Account title'),
                ),
                AppSizes.hMd,
                CustomTextField(
                  label: isBank ? 'Bank name (optional)' : 'Wallet name (optional)',
                  hint: isBank ? 'e.g. Meezan Bank' : 'e.g. EasyPaisa, JazzCash',
                  controller: d.providerCtrl,
                ),
                AppSizes.hMd,
                CustomTextField(
                  label: 'Account number',
                  hint: isBank ? 'Account number or IBAN' : 'Mobile account number',
                  controller: d.numberCtrl,
                  textInputAction: TextInputAction.done,
                  validator: (v) => c.validateAccountNumber(d, v),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.black : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          label,
          style: AppTextStyles.smallSemiBold.copyWith(
              color: selected ? AppColors.white : Colors.black),
        ),
      ),
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
        ShimmerLoader(height: 200, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 260, radius: AppSizes.radiusLg),
      ],
    );
  }
}