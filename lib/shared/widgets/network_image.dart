import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/app_sizes.dart';
import 'shimmer_loader.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = AppSizes.radiusMd,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: (url == null || url!.isEmpty)
          ? _fallback()
          : CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) =>
            ShimmerLoader(width: width, height: height ?? 100, radius: 0),
        errorWidget: (_, __, ___) => _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
    width: width,
    height: height,
    color: AppColors.gray100,
    child: const Icon(Icons.image_not_supported_outlined,
        color: AppColors.gray400),
  );
}