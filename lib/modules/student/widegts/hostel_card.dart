import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/network_image.dart';
import 'hostel_listing.dart';

class HostelCard extends StatelessWidget {
  final HostelListing listing;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onView;

  const HostelCard({
    super.key,
    required this.listing,
    required this.isFavorite,
    required this.onFavorite,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final h = listing.hostel;
    final location =
    [h.city, h.address].where((e) => e.trim().isNotEmpty).join(', ');
    final beds = listing.availableBeds;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppNetworkImage(
                url: h.images.isNotEmpty ? h.images.first : null,
                width: double.infinity,
                height: 170,
                radius: AppSizes.radiusMd,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkResponse(
                  onTap: onFavorite,
                  radius: 22,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(h.name,
                          style: AppTextStyles.oneLinerSemiBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    _Badge(isFull: listing.isFull),
                  ],
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(location,
                            style: AppTextStyles.smallRegular
                                .copyWith(color: AppColors.gray600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  children: [
                    Text(
                      h.monthlyPrice > 0
                          ? '${Formatters.currency(h.monthlyPrice)}/month'
                          : 'Price not set',
                      style: AppTextStyles.smallSemiBold,
                    ),
                    if (beds != null) ...[
                      Text('  |  ', style: AppTextStyles.smallRegular),
                      Text('$beds ${beds == 1 ? 'Bed' : 'Beds'} free',
                          style: AppTextStyles.smallRegular),
                    ],
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                  child: Divider(height: 1, color: AppColors.border),
                ),
              ],
            ),
          ),
          PrimaryButton(text: 'View Details', onPressed: onView),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final bool isFull;
  const _Badge({required this.isFull});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isFull ? AppColors.error : AppColors.success,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        isFull ? 'Full' : 'Available',
        style: AppTextStyles.smallSemiBold
            .copyWith(color: AppColors.white, fontSize: 10),
      ),
    );
  }
}