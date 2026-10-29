import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import 'student_drawer.dart';

/// Student ki har screen ka frame: [menu] title ....... [icons]
/// Menu (hamburger) drawer kholta hai.
class StudentScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final String currentRoute;

  const StudentScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentRoute,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: StudentDrawer(currentRoute: currentRoute),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding, AppSizes.md, AppSizes.screenPadding, 0),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => StudentHeaderIcon(
                      icon: Icons.menu_rounded,
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.screenTitle
                          .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    actions[i],
                  ],
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// Gol chhota icon. [active] = purple (jaise filter laga ho)
class StudentHeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const StudentHeaderIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.primary : AppColors.white,
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Icon(icon,
            size: 18, color: active ? AppColors.white : Colors.black),
      ),
    );
  }
}