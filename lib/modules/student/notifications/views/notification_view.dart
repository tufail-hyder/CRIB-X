import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../widegts/time_ago.dart';
import '../controllers/notification_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.sm, AppSizes.sm, AppSizes.screenPadding, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: AppTextStyles.screenTitle
                          .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Obx(() => c.unreadCount > 0
                      ? TextButton(
                    onPressed: c.markAllRead,
                    child: Text('Mark all read',
                        style: AppTextStyles.smallSemiBold
                            .copyWith(color: AppColors.primary)),
                  )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final list = c.items;

                if (list.isEmpty) {
                  if (c.isLoading.value) return const _Loading();
                  if (c.errorMessage.value != null) {
                    return EmptyState(
                      icon: Icons.error_outline,
                      title: 'Could not load notifications',
                      message: c.errorMessage.value,
                      actionText: 'Retry',
                      onAction: c.load,
                    );
                  }
                  return const EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No notifications yet',
                    message: 'Updates about your bookings and payments will show up here.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: c.load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => AppSizes.hSm,
                    itemBuilder: (_, i) =>
                        _Tile(item: list[i], onTap: () => c.open(list[i])),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;
  const _Tile({required this.item, required this.onTap});

  (IconData, Color, Color) get _style {
    switch (item.type) {
      case NotificationType.booking:
        return (Icons.event_available_rounded, const Color(0xFFEDE9FE), const Color(0xFF7C3AED));
      case NotificationType.payment:
        return (Icons.payments_rounded, const Color(0xFFDCFCE7), const Color(0xFF15803D));
      case NotificationType.rentDue:
        return (Icons.warning_amber_rounded, const Color(0xFFFEF3C7), const Color(0xFFB45309));
      case NotificationType.complaint:
        return (Icons.report_problem_rounded, const Color(0xFFFEE2E2), const Color(0xFFB91C1C));
      case NotificationType.general:
        return (Icons.notifications_rounded, const Color(0xFFDBEAFE), const Color(0xFF1D4ED8));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = _style;
    final unread = !item.isRead;

    return Material(
      color: unread ? const Color(0xFFF8F7FF) : AppColors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: fg),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.oneLinerSemiBold.copyWith(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(item.body,
                        style: AppTextStyles.smallRegular
                            .copyWith(color: AppColors.gray600)),
                    const SizedBox(height: 6),
                    Text(
                      item.isDerived ? 'Reminder' : timeAgo(item.createdAt),
                      style: AppTextStyles.smallRegular
                          .copyWith(color: AppColors.gray400, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
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
      children: [
        ShimmerLoader(height: 76, radius: AppSizes.radiusMd),
        AppSizes.hSm,
        ShimmerLoader(height: 76, radius: AppSizes.radiusMd),
        AppSizes.hSm,
        ShimmerLoader(height: 76, radius: AppSizes.radiusMd),
      ],
    );
  }
}