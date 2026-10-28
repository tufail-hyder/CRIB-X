import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/exceptions/exception_handler.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/popups/app_dialogs.dart';
import '../../../shared/popups/app_snackbar.dart';

class StudentDrawer extends StatelessWidget {
  final String currentRoute;
  const StudentDrawer({super.key, required this.currentRoute});

  Future<void> _logout() async {
    final ok = await AppDialogs.confirm(
      title: 'Log out?',
      message: 'You will need to log in again to use the app.',
      confirmText: 'Log out',
      isDestructive: true,
    );
    if (ok != true) return;

    try {
      await Get.find<AuthRepository>().logout();
      Get.offAllNamed(AppRoutes.studentLogin);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  @override
  Widget build(BuildContext context) {
    final onDashboard = currentRoute == AppRoutes.studentHome;

    return Drawer(
      backgroundColor: AppColors.white,
      width: 250,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 110,
            color: const Color(0xFF0A1214),
            alignment: Alignment.center,
            child: Text(
              'CRIB X',
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.white,
                fontSize: 24,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Item(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            selected: onDashboard,
            onTap: () {
              Get.back();
              if (!onDashboard) Get.offAllNamed(AppRoutes.studentHome);
            },
          ),
          _Item(
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            onTap: () {
              Get.back();
              AppSnackbar.info('Favorites screen is coming next.');
            },
          ),
          _Item(
            icon: Icons.settings_rounded,
            label: 'Profile Setting',
            onTap: () {
              Get.back();
              AppSnackbar.info('Profile screen is coming next.');
            },
          ),
          _Item(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: () {
              Get.back();
              _logout();
            },
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : AppColors.gray600;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.gray100 : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppTextStyles.oneLinerRegular.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}