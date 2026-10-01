import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/dashboard_stats_model.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class MonthlyIncomeChart extends StatelessWidget {
  final List<IncomePoint> points;
  const MonthlyIncomeChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Income', style: AppTextStyles.sectionInnerTitle),
          AppSizes.hLg,
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: 0,
                maxY: 10000,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2000,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.gray200,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 2000,
                      getTitlesWidget: (v, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          v == 0 ? '0' : '${(v / 1000).toInt()}k',
                          style: AppTextStyles.smallRegular,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (v != i || i < 0 || i >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(points[i].label,
                              style: AppTextStyles.smallRegular),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.dark,
                    getTooltipItems: (touched) => touched
                        .map((s) => LineTooltipItem(
                      'Sales\n${s.y.toStringAsFixed(0)}',
                      AppTextStyles.smallSemiBold
                          .copyWith(color: AppColors.white),
                    ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.25,
                    barWidth: 3,
                    gradient: const LinearGradient(
                      colors: [AppColors.info, AppColors.primary],
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.white,
                            strokeWidth: 2,
                            strokeColor: AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}