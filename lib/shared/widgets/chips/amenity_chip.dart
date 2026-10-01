import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class AmenityIcons {
  AmenityIcons._();

  static IconData of(String name) {
    final n = name.toLowerCase();
    if (n.contains('sheet')) return Icons.hotel_rounded;
    if (n.contains('bed')) return Icons.bed_rounded;
    if (n.contains('carpet')) return Icons.texture_rounded;
    if (n.contains('mess') || n.contains('meal') || n.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (n.contains('mosque')) return Icons.mosque_rounded;
    if (n.contains('wifi') || n.contains('internet')) return Icons.wifi_rounded;
    if (n == 'ac' || n.contains('air')) return Icons.ac_unit_rounded;
    if (n.contains('laundry')) return Icons.local_laundry_service_rounded;
    if (n.contains('parking')) return Icons.local_parking_rounded;
    if (n.contains('geyser') || n.contains('water')) {
      return Icons.water_drop_rounded;
    }
    if (n.contains('security') || n.contains('cctv')) {
      return Icons.security_rounded;
    }
    if (n.contains('ups') || n.contains('generator') || n.contains('electric')) {
      return Icons.bolt_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }
}

class AmenityChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;
  const AmenityChip({super.key, required this.label, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AmenityIcons.of(label),
              size: AppSizes.iconMd, color: AppColors.dark),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.smallSemiBold),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: AppSizes.iconSm, color: AppColors.gray500),
            ),
          ],
        ],
      ),
    );
  }
}