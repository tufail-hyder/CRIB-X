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
    return Column(
      children: [
        Expanded(child: child),
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: network.isOnline.value ? 0 : 32,
          width: double.infinity,
          color: AppColors.error,
          alignment: Alignment.center,
          child: network.isOnline.value
              ? const SizedBox.shrink()
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off,
                  size: AppSizes.iconSm, color: AppColors.white),
              AppSizes.wSm,
              Text(AppStrings.noInternetTitle,
                style: AppTextStyles.smallSemiBold.copyWith(color: AppColors.white),
              ),
            ],
          ),
        )),
      ],
    );
  }
}