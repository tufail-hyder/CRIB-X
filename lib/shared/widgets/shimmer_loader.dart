import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_sizes.dart';

class ShimmerLoader extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerLoader({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppSizes.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}