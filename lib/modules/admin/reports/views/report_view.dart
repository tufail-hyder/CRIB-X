import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../payments/widgets/monthly_income_chart.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/report_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Reports',
      body: Obx(() {
        final firstLoad = c.isLoading.value && c.payments.isEmpty && c.rooms.isEmpty;
        if (firstLoad) return const _Loading();

        if (c.errorMessage.value != null && c.payments.isEmpty) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load report',
            message: c.errorMessage.value,
            actionText: 'Retry',
            onAction: c.load,
          );
        }

        return RefreshIndicator(
          onRefresh: c.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: [
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: ReportPeriod.values
                    .map((p) => _Chip(
                  label: p.label,
                  selected: c.period.value == p,
                  onTap: () => c.setPeriod(p),
                ))
                    .toList(),
              ),
              AppSizes.hMd,
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSizes.md,
                crossAxisSpacing: AppSizes.md,
                childAspectRatio: 2.3,
                children: [
                  StatCard(
                    icon: Icons.payments_rounded,
                    value: Formatters.currency(c.revenue),
                    label: 'Revenue Collected',
                    color: AppColors.primary,
                  ),
                  StatCard(
                    icon: Icons.receipt_long_rounded,
                    value: Formatters.currency(c.outstandingFees),
                    label: 'Outstanding (this month)',
                    color: AppColors.warning,
                  ),
                  StatCard(
                    icon: Icons.login_rounded,
                    value: '${c.newCheckIns}',
                    label: 'New Check-ins',
                    color: const Color(0xFFFACC15),
                  ),
                  StatCard(
                    icon: Icons.bed_rounded,
                    value: '${c.occupancyPercent}%',
                    label: 'Bed Occupancy',
                    color: AppColors.info,
                  ),
                ],
              ),
              AppSizes.hMd,
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 190,
                  child: PrimaryButton(
                      text: 'Copy Summary', onPressed: c.copySummary),
                ),
              ),
              AppSizes.hLg,
              MonthlyIncomeChart(
                points: c.revenuePoints,
                title: 'Revenue',
                tooltipLabel: 'Revenue',
              ),
              AppSizes.hLg,
              SectionCard(
                title: 'Payment Methods',
                child: c.methodShares.isEmpty
                    ? const _Empty('No payments in this period')
                    : Column(
                  children: c.methodShares
                      .map((m) => _BarRow(
                    label: m.method.label,
                    trailing:
                    '${Formatters.currency(m.amount)} · ${(m.share * 100).round()}%',
                    value: m.share,
                  ))
                      .toList(),
                ),
              ),
              AppSizes.hLg,
              SectionCard(
                title: 'Occupancy by Room Type',
                child: c.occupancyBySeater.isEmpty
                    ? const _Empty('No rooms added yet')
                    : Column(
                  children: c.occupancyBySeater
                      .map((o) => _BarRow(
                    label: '${o.seater} seater',
                    trailing: '${o.occupiedBeds}/${o.totalBeds} beds',
                    value: o.ratio,
                  ))
                      .toList(),
                ),
              ),
              AppSizes.hLg,
              SectionCard(
                title: 'Complaints',
                child: Column(
                  children: [
                    _InfoRow('Total complaints', '${c.complaintsTotal}'),
                    _InfoRow('Resolved', '${c.complaintsResolved}'),
                    _InfoRow('Still open', '${c.complaintsOpen}'),
                    _InfoRow('Avg. resolution time', c.avgResolution),
                    if (c.complaintsByCategory.isNotEmpty) ...[
                      AppSizes.hSm,
                      const Divider(height: 1, color: AppColors.border),
                      AppSizes.hSm,
                      ...c.complaintsByCategory.map((e) => _BarRow(
                        label: e.category.label,
                        trailing: '${e.count}',
                        value: c.complaintsTotal == 0
                            ? 0
                            : e.count / c.complaintsTotal,
                      )),
                    ],
                  ],
                ),
              ),
              AppSizes.hLg,
              SectionCard(
                title: 'Outstanding Fees (this month)',
                child: c.topOutstanding.isEmpty
                    ? const _Empty('No pending fees. Everyone is paid up.')
                    : Column(
                  children: [
                    ...c.topOutstanding.map((s) {
                      final key = DateTime.now();
                      final month =
                          '${key.year}-${key.month.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(s.name,
                                      style: AppTextStyles.smallRegular,
                                      overflow: TextOverflow.ellipsis),
                                  Text(
                                    'Room ${s.roomNumber} · Paid ${Formatters.currency(s.paidFor(month))} of ${Formatters.currency(s.monthlyFee)}',
                                    style: AppTextStyles.smallRegular
                                        .copyWith(
                                        color: AppColors.gray600,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.currency(s.remainingFor(month)),
                              style: AppTextStyles.smallSemiBold
                                  .copyWith(color: AppColors.error),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (c.outstandingCount > c.topOutstanding.length)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.sm),
                        child: Text(
                          '+ ${c.outstandingCount - c.topOutstanding.length} more students',
                          style: AppTextStyles.smallRegular
                              .copyWith(color: AppColors.gray600),
                        ),
                      ),
                  ],
                ),
              ),
              AppSizes.hLg,
            ],
          ),
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          label,
          style: AppTextStyles.smallSemiBold.copyWith(
              color: selected ? AppColors.white : Colors.black),
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final String trailing;
  final double value; // 0..1
  const _BarRow(
      {required this.label, required this.trailing, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.smallRegular)),
              Text(trailing, style: AppTextStyles.smallSemiBold),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: AppColors.gray200,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.smallRegular)),
          Text(value, style: AppTextStyles.smallSemiBold),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
    child: Text(text,
        style: AppTextStyles.smallRegular.copyWith(color: AppColors.gray600)),
  );
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: const [
        ShimmerLoader(height: 36, radius: AppSizes.radiusMd),
        AppSizes.hMd,
        ShimmerLoader(height: 140, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 260, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 160, radius: AppSizes.radiusLg),
      ],
    );
  }
}