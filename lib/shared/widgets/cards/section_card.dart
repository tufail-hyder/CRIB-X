import 'package:flutter/material.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import 'app_card.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionInnerTitle),
          AppSizes.hLg,
          child,
        ],
      ),
    );
  }
}