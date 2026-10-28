import 'package:crib_x/modules/student/widegts/student_drawer.dart';
import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

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
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.screenTitle
                          .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final a in actions) ...[a, const SizedBox(width: 8)],
                  Builder(
                    builder: (ctx) => StudentHeaderIcon(
                      icon: Icons.sort_rounded,
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
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

class StudentHeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const StudentHeaderIcon({super.key, required this.icon, required this.onTap});

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
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}