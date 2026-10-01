import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_assets.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/exceptions/exception_handler.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/popups/app_dialogs.dart';
import '../../../shared/popups/app_snackbar.dart';
import '../../../shared/popups/full_screen_loader.dart';
import 'admin_menu.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  void _go(BuildContext context, AdminMenuItem item) {
    Navigator.of(context).pop();
    if (Get.currentRoute == item.route) return;

    if (item.route == AppRoutes.adminDashboard) {
      Get.until((r) => r.settings.name == AppRoutes.adminDashboard);
    } else {
      Get.offNamedUntil(
        item.route,
            (r) => r.settings.name == AppRoutes.adminDashboard,
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pop();

    final confirmed = await AppDialogs.confirm(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      FullScreenLoader.show('Logging out...');
      await Get.find<AuthRepository>().logout();
      FullScreenLoader.hide();
      Get.offAllNamed(AppRoutes.adminLogin);
    } catch (e, s) {
      FullScreenLoader.hide();
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = Get.currentRoute;
    final top = MediaQuery.of(context).padding.top;

    return Drawer(
      backgroundColor: AppColors.white,
      width: 270,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 90 + top,
            padding: EdgeInsets.only(top: top),
            color: AppColors.dark,
            alignment: Alignment.center,
            child: Image.asset(AppAssets.logoDark, width: 130),
          ),
          AppSizes.hLg,
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final item in adminMenu)
                  _DrawerTile(
                    title: item.title,
                    icon: item.icon,
                    selected: current == item.route,
                    onTap: () => _go(context, item),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          SafeArea(
            top: false,
            child: _DrawerTile(
              title: 'Logout',
              icon: Icons.logout_rounded,
              color: AppColors.error,
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final Color? color; 
  final VoidCallback onTap;

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor =
        color ?? (selected ? AppColors.dark : AppColors.gray500);

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
        decoration: selected
            ? const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gray200, AppColors.white],
          ),
        )
            : null,
        child: Row(
          children: [
            Icon(icon, size: AppSizes.iconLg, color: tileColor),
            const SizedBox(width: AppSizes.lg),
            Text(
              title,
              style: (selected
                  ? AppTextStyles.oneLinerSemiBold
                  : AppTextStyles.oneLinerRegular)
                  .copyWith(color: tileColor),
            ),
          ],
        ),
      ),
    );
  }
}