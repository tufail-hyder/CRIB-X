import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_sizes.dart';
import '../../core/constant/app_strings.dart';
import '../../core/network/network_manager.dart';
import '../../core/theme/app_text_styles.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final network = NetworkManager.instance;

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Obx(() {
              if (network.isOnline.value) return const SizedBox.shrink();
              return SafeArea(
                top: false,
                child: Center(
                  child: Material(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.lg, vertical: AppSizes.sm),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off,
                              size: AppSizes.iconSm, color: AppColors.white),
                          AppSizes.wSm,
                          Text(
                            AppStrings.noInternetTitle,
                            style: AppTextStyles.smallSemiBold
                                .copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}