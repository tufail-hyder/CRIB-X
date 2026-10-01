import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../shared/widgets/network_image.dart';
import '../hostel_profile/controllers/hostel_profile_controller.dart';

class HostelImagesCard extends StatelessWidget {
  final HostelProfileController c;
  const HostelImagesCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Hostel Images',
      child: Obx(() {
        final uploading = c.isUploading.value;
        return Column(
          children: [
            InkWell(
              onTap: uploading ? null : c.pickImages,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: uploading
                    ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2.5))
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        size: 36, color: AppColors.gray500),
                    AppSizes.hSm,
                    Text('Upload Image',
                        style: AppTextStyles.smallSemiBold),
                    Text(
                      '${c.images.length}/${HostelProfileController.maxImages}',
                      style: AppTextStyles.smallRegular,
                    ),
                  ],
                ),
              ),
            ),
            if (c.images.isNotEmpty) ...[
              AppSizes.hMd,
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: c.images.length,
                  separatorBuilder: (_, __) => AppSizes.wSm,
                  itemBuilder: (_, i) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppNetworkImage(
                        url: c.images[i],
                        width: 64,
                        height: 64,
                        radius: AppSizes.radiusSm,
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => c.removeImage(i),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.dark,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 12, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}