import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_sizes.dart';
import '../../core/constant/app_strings.dart';
import '../../core/theme/app_text_styles.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.gray400), AppSizes.hLg,
            Text(AppStrings.noInternetTitle, style: AppTextStyles.sectionTitle), AppSizes.hSm,
            Text(AppStrings.noInternetMsg, textAlign: TextAlign.center, style: AppTextStyles.body),
            AppSizes.hXl,
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}