import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/inputs/custom_search_bar.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../hostel_detail/widgets/hostel_card.dart';
import '../../widegts/student_scaffold.dart';
import '../controllers/favorite_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return StudentScaffold(
      title: 'Favorites',
      currentRoute: AppRoutes.studentFavorites,
      actions: [
        StudentHeaderIcon(icon: Icons.search_rounded, onTap: c.toggleSearch),
        StudentHeaderIcon(
            icon: Icons.notifications_none_rounded, onTap: c.openNotifications),
        Obx(() => StudentHeaderIcon(
          icon: Icons.tune_rounded,
          active: c.filter.value.isActive,
          onTap: c.openFilters,
        )),
      ],
      body: Obx(() {
        if (c.allListings.isEmpty) {
          if (c.isLoading.value) return const _Loading();
          if (c.errorMessage.value != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load favorites',
              message: c.errorMessage.value,
              actionText: 'Retry',
              onAction: c.load,
            );
          }
        }

        final list = c.visible;
        final hasNone = c.entries.isEmpty;
        final narrowed = c.filter.value.isActive ||
            c.period.value != FavPeriod.all ||
            c.query.value.isNotEmpty;

        return RefreshIndicator(
          onRefresh: c.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: [
              if (c.showSearch.value) ...[
                CustomSearchBar(
                  hint: 'Search favorites',
                  onChanged: c.setQuery,
                ),
                AppSizes.hMd,
              ],
              Row(
                children: [
                  Text(
                    'Hostels',
                    style: AppTextStyles.sectionInnerTitle
                        .copyWith(color: AppColors.primary, fontSize: 18),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        children: FavPeriod.values
                            .map((p) => Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _Chip(
                            label: p.label,
                            selected: c.period.value == p,
                            onTap: () => c.setPeriod(p),
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              AppSizes.hMd,
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.xl),
                  child: hasNone
                      ? EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'No favorites yet',
                    message:
                    'Tap the heart on a hostel to save it here.',
                    actionText: 'Browse hostels',
                    onAction: c.browseHostels,
                  )
                      : EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No saved hostels found',
                    message: narrowed
                        ? 'Nothing matches your filters.'
                        : 'These hostels are no longer available.',
                    actionText: narrowed ? 'Reset filters' : null,
                    onAction: narrowed ? c.resetFilters : null,
                  ),
                )
              else
                ...list.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.lg),
                  child: HostelCard(
                    listing: l,
                    isFavorite: true,
                    onFavorite: () => c.removeFavorite(l.hostel.id),
                    onView: () => c.viewDetails(l),
                  ),
                )),
            ],
          ),
        );
      }),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.black : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          label,
          style: AppTextStyles.smallSemiBold.copyWith(
              fontSize: 11,
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
        ShimmerLoader(height: 32, radius: AppSizes.radiusMd),
        AppSizes.hMd,
        ShimmerLoader(height: 320, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 320, radius: AppSizes.radiusLg),
      ],
    );
  }
}