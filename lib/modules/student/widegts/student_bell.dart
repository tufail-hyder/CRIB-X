import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/notification_model.dart';
import 'bell_badge.dart';
import 'student_scaffold.dart';

class StudentBell extends StatelessWidget {
  const StudentBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BellBadge(
      scope: NotificationScope.student,
      child: StudentHeaderIcon(
        icon: Icons.notifications_none_rounded,
        onTap: () => Get.toNamed(AppRoutes.studentNotifications),
      ),
    );
  }
}