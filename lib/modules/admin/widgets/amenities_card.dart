import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/chips/amenity_chip.dart';
import '../hostel_profile/controllers/hostel_profile_controller.dart';

class AmenitiesCard extends StatelessWidget {
  final HostelProfileController c;
  const AmenitiesCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Amenities',
      child: Obx(
            () => Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            for (final a in c.amenities.toList())
              AmenityChip(label: a, onRemove: () => c.removeAmenity(a)),
            InkWell(
              onTap: c.addAmenity,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add,
                        size: AppSizes.iconMd, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text('Add',
                        style: AppTextStyles.smallSemiBold
                            .copyWith(color: AppColors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}