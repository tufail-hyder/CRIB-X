import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget> actions;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions = const [],
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.white,
      titleSpacing: AppSizes.screenPadding,
      leading: showBack
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: AppSizes.iconMd),
        onPressed: onBack ?? () => Get.back(),
      )
          : null,
      title: Text(title, style: AppTextStyles.sectionTitle),
      actions: [
        ...actions,
        const SizedBox(width: AppSizes.screenPadding),
      ],
    );
  }
}

class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDot;

  const AppBarIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: Stack(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppSizes.iconMd, color: AppColors.dark),
            ),
            if (showDot)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}