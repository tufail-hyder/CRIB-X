import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/network_image.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../widegts/student_scaffold.dart';
import '../controllers/student_profile_controller.dart';

class StudentProfileView extends GetView<StudentProfileController> {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return StudentScaffold(
      title: 'Profile',
      currentRoute: AppRoutes.studentProfile,
      actions: [
        StudentHeaderIcon(
            icon: Icons.notifications_none_rounded, onTap: c.openNotifications),
      ],
      body: Obx(() {
        if (!c.isLoaded.value) {
          if (c.isLoading.value) return const _Loading();
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load profile',
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
              Text(
                'Profile Setting',
                style: AppTextStyles.sectionInnerTitle
                    .copyWith(color: AppColors.primary, fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your personal information, account security and preferences.',
                style: AppTextStyles.smallRegular
                    .copyWith(color: AppColors.gray600, fontSize: 11),
              ),
              AppSizes.hMd,

              // ---------------- Personal Information ----------------
              SectionCard(
                title: 'Personal Information',
                child: Column(
                  children: [
                    Obx(() => c.photoUrl.value == null
                        ? Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(Icons.person,
                          size: 64, color: AppColors.gray400),
                    )
                        : AppNetworkImage(
                      url: c.photoUrl.value,
                      width: double.infinity,
                      height: 150,
                      radius: AppSizes.radiusMd,
                    )),
                    AppSizes.hMd,
                    Obx(() => PrimaryButton(
                      text: 'Upload Photo',
                      isOutlined: true,
                      isLoading: c.isUploadingPhoto.value,
                      onPressed: c.pickPhoto,
                    )),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Your Name',
                      hint: 'Your name',
                      controller: c.nameCtrl,
                      validator: (v) => Validators.required(v, 'Name'),
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Email',
                      hint: 'Email',
                      controller: c.emailCtrl,
                      enabled: false, // email yahan se nahi badalta
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'Phone number',
                      hint: '03XXXXXXXXX',
                      controller: c.phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                    ),
                    AppSizes.hMd,
                    CustomTextField(
                      label: 'City',
                      hint: 'e.g. Islamabad',
                      controller: c.cityCtrl,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
              AppSizes.hLg,

              // ---------------- Account Security ----------------
              SectionCard(
                title: 'Account Security',
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

              // ---------------- Logout ----------------
              _LogoutButton(onTap: c.logout),
              AppSizes.hLg,

              Row(
                children: [
                  Expanded(
                    child: Obx(() => PrimaryButton(
                      text: 'Save and change',
                      isLoading: c.isSaving.value,
                      onPressed: c.save,
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
              AppSizes.hLg,
            ],
          ),
        );
      }),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDE2E2),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text('Logout',
                  style: AppTextStyles.oneLinerSemiBold
                      .copyWith(color: AppColors.error)),
              const Spacer(),
              const Icon(Icons.logout_rounded,
                  size: 20, color: AppColors.error),
            ],
          ),
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
        ShimmerLoader(height: 40, radius: AppSizes.radiusMd),
        AppSizes.hMd,
        ShimmerLoader(height: 460, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 260, radius: AppSizes.radiusLg),
      ],
    );
  }
}