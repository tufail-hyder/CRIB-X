import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/app_bar/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/analytics_donut.dart';
import '../../widgets/monthly_income_chart.dart';
import '../../widgets/recent_students_card.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../core/constant/app_colors.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      actions: const [
        AppBarIconButton(icon: Icons.search_rounded),
      ],
      body: Obx(() {
        final stats = controller.stats.value;

        if (stats == null) {
          if (controller.isLoading.value) return const _DashboardShimmer();
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load dashboard',
            message: controller.errorMessage.value,
            actionText: 'Retry',
            onAction: controller.load,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSizes.md,
                crossAxisSpacing: AppSizes.md,
                childAspectRatio: 2.3,
                children: [
                  StatCard(
                    icon: Icons.meeting_room_rounded,
                    value: '${stats.totalRooms}',
                    label: 'Total Rooms',
                    color: AppColors.primary,
                  ),
                  StatCard(
                    icon: Icons.bed_rounded,
                    value: '${stats.occupiedBeds}',
                    label: 'Occupied Beds',
                    color: const Color(0xFFFACC15),
                  ),
                  StatCard(
                    icon: Icons.receipt_long_rounded,
                    value: '${stats.pendingPayments}',
                    label: 'Pending payments',
                    color: AppColors.warning,
                  ),
                  StatCard(
                    icon: Icons.payments_rounded,
                    value: Formatters.currency(stats.monthlyRevenue),
                    label: 'Monthly Revenue',
                    color: AppColors.info,
                  ),
                ],
              ),
              AppSizes.hLg,
              MonthlyIncomeChart(points: stats.income),
              AppSizes.hLg,
              AnalyticsDonut(breakdown: stats.breakdown),
              AppSizes.hLg,
              RecentStudentsCard(students: stats.recentStudents),
              AppSizes.hLg,
            ],
          ),
        );
      }),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: const [
        ShimmerLoader(height: 140, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 260, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 300, radius: AppSizes.radiusLg),
      ],
    );
  }
}