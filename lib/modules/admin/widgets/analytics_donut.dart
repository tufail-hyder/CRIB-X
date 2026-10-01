import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/dashboard_stats_model.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class AnalyticsDonut extends StatelessWidget {
  final PaymentBreakdown breakdown;
  const AnalyticsDonut({super.key, required this.breakdown});

  static const _paidColor = AppColors.info;
  static const _pendingColor = Color(0xFFFACC15);
  static const _dueColor = AppColors.warning;

  PieChartSectionData _section(double value, Color color) =>
      PieChartSectionData(
        value: value,
        color: color,
        radius: 24,
        showTitle: false,
      );

  @override
  Widget build(BuildContext context) {
    final empty = breakdown.total == 0;

    return AppCard(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Analytics', style: AppTextStyles.sectionInnerTitle),
          ),
          AppSizes.hLg,
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 2,
                    centerSpaceRadius: 70,
                    borderData: FlBorderData(show: false),
                    sections: empty
                        ? [_section(1, AppColors.gray200)]
                        : [
                      _section(breakdown.paid, _paidColor),
                      _section(breakdown.pending, _pendingColor),
                      _section(breakdown.due, _dueColor),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${breakdown.paidPercent}%',
                      style: AppTextStyles.screenTitle
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text('Transactions', style: AppTextStyles.smallRegular),
                  ],
                ),
              ],
            ),
          ),
          AppSizes.hXl,
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Legend(color: _paidColor, label: 'Paid'),
              _Legend(color: _pendingColor, label: 'Pending'),
              _Legend(color: _dueColor, label: 'Due'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        AppSizes.wSm,
        Text(label, style: AppTextStyles.smallRegular),
      ],
    );
  }
}