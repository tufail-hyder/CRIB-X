import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/inputs/custom_search_bar.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../widegts/hostel_card.dart';
import '../../widegts/student_scaffold.dart';
import '../controllers/student_dashboard_controller.dart';

class StudentDashboardView extends GetView<StudentDashboardController> {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return StudentScaffold(
      title: 'Dashboard',
      currentRoute: AppRoutes.studentHome,
      actions: [
        StudentHeaderIcon(icon: Icons.search_rounded, onTap: c.toggleSearch),
        StudentHeaderIcon(
            icon: Icons.notifications_none_rounded, onTap: c.openNotifications),
      ],
      body: Obx(() {
        if (c.listings.isEmpty) {
          if (c.isLoading.value) return const _Loading();
          if (c.errorMessage.value != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load hostels',
              message: c.errorMessage.value,
              actionText: 'Retry',
              onAction: c.load,
            );
          }
        }

        final list = c.visible;

        return RefreshIndicator(
          onRefresh: c.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: [
              if (c.showSearch.value) ...[
                CustomSearchBar(
                  hint: 'Search hostel or city',
                  onChanged: c.setQuery,
                ),
                AppSizes.hMd,
              ],
              if (c.showBanner.value) ...[
                _Banner(onClose: c.dismissBanner),
                AppSizes.hMd,
              ],
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
                    value: c.roomBedText,
                    label: 'Room / Bed',
                    color: AppColors.primary,
                  ),
                  StatCard(
                    icon: Icons.event_rounded,
                    value: c.nextDueText,
                    label: 'Next Due Date',
                    color: const Color(0xFFFACC15),
                  ),
                  StatCard(
                    icon: Icons.receipt_long_rounded,
                    value: c.rentStatusText,
                    label: 'Rent Status',
                    color: AppColors.warning,
                  ),
                  StatCard(
                    icon: Icons.hourglass_bottom_rounded,
                    value: c.stayDurationText,
                    label: 'Stay Duration',
                    color: AppColors.info,
                  ),
                ],
              ),
              AppSizes.hMd,
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: HomeTab.values
                    .map((t) => _Chip(
                  label: t.label,
                  selected: c.tab.value == t,
                  onTap: () => c.setTab(t),
                ))
                    .toList(),
              ),
              AppSizes.hMd,
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSizes.xl),
                  child: EmptyState(
                    icon: Icons.apartment_rounded,
                    title: 'No hostels found',
                    message: 'Try a different search or tab.',
                  ),
                )
              else
                ...list.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.lg),
                  child: HostelCard(
                    listing: l,
                    isFavorite: c.favorites.contains(l.hostel.id),
                    onFavorite: () => c.toggleFavorite(l.hostel.id),
                    onView: () => c.viewDetails(l.hostel),
                  ),
                )),
            ],
          ),
        );
      }),
    );
  }
}

class _Banner extends StatelessWidget {
  final VoidCallback onClose;
  const _Banner({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Ready to find your new home?',
                style: AppTextStyles.smallRegular),
          ),
          InkResponse(
            onTap: onClose,
            radius: 18,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        ShimmerLoader(height: 44, radius: AppSizes.radiusMd),
        AppSizes.hMd,
        ShimmerLoader(height: 140, radius: AppSizes.radiusLg),
        AppSizes.hMd,
        ShimmerLoader(height: 320, radius: AppSizes.radiusLg),
      ],
    );
  }
}