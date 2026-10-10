import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/student_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/network_image.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../students/widgets/payment_bridge.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/payment_controller.dart';
import '../widgets/monthly_income_chart.dart';

class PaymentsView extends GetView<PaymentsController> {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Payments',
      body: Obx(() {
        if (c.students.isEmpty) {
          if (c.isLoading.value) return const _Loading();
          if (c.errorMessage.value != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load payments',
              message: c.errorMessage.value,
              actionText: 'Retry',
              onAction: c.listen,
            );
          }
        }

        final list = c.filtered;

        return ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          children: [
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
                  value: Formatters.currency(c.monthRevenue),
                  label: 'Monthly Revenue',
                  color: AppColors.primary,
                ),
                StatCard(
                  icon: Icons.check_circle_rounded,
                  value: '${c.paidCount}',
                  label: 'Paid',
                  color: const Color(0xFFFACC15),
                ),
                StatCard(
                  icon: Icons.hourglass_top_rounded,
                  value: '${c.pendingCount}',
                  label: 'Pending payments',
                  color: AppColors.warning,
                ),
                StatCard(
                  icon: Icons.error_outline_rounded,
                  value: '${c.overdueCount}',
                  label: 'Overdue',
                  color: AppColors.info,
                ),
              ],
            ),
            AppSizes.hMd,
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                _Chip(
                  label: 'All',
                  selected: c.filter.value == null,
                  onTap: () => c.filter.value = null,
                ),
                _Chip(
                  label: 'Paid',
                  selected: c.filter.value == PaymentStatus.paid,
                  onTap: () => c.filter.value = PaymentStatus.paid,
                ),
                _Chip(
                  label: 'Pending',
                  selected: c.filter.value == PaymentStatus.pending,
                  onTap: () => c.filter.value = PaymentStatus.pending,
                ),
                _Chip(
                  label: 'Overdue',
                  selected: c.filter.value == PaymentStatus.due,
                  onTap: () => c.filter.value = PaymentStatus.due,
                ),
              ],
            ),
            AppSizes.hMd,
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 190,
                child: PrimaryButton(
                    text: 'Record Payment', onPressed: () => c.openRecord()),
              ),
            ),
            AppSizes.hLg,
            MonthlyIncomeChart(points: c.revenuePoints),
            AppSizes.hLg,
            SectionCard(
              title: 'Students',
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Student', style: AppTextStyles.label),
                        Text('Payments', style: AppTextStyles.label),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSizes.xl),
                      child: Text('No students found'),
                    )
                  else
                    ...list.map((s) => _PaymentRow(
                      student: s,
                      onTap: () => c.openRecord(s),
                    )),
                ],
              ),
            ),
            AppSizes.hLg,
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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

class _PaymentRow extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;
  const _PaymentRow({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final key = StudentModel.monthKey(DateTime.now());
    final paid = student.paidFor(key);
    final status = student.paymentStatus;

    // Partial payment ho to dikhao: "Paid 5,000 of 15,000"
    final subtitle = (status != PaymentStatus.paid && paid > 0)
        ? 'Paid ${Formatters.currency(paid)} of ${Formatters.currency(student.monthlyFee)}'
        : 'Room ${student.roomNumber} · ${student.bed}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AppNetworkImage(
                url: student.photoUrl, width: 32, height: 32, radius: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: AppTextStyles.smallRegular,
                      overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style: AppTextStyles.smallRegular
                          .copyWith(color: AppColors.gray600, fontSize: 11),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            PaymentBadge(status: status),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: const [
        ShimmerLoader(height: 140, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 260, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 240, radius: AppSizes.radiusLg),
      ],
    );
  }
}