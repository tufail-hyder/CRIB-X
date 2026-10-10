import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/complaint_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../payments/widgets/monthly_income_chart.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/compaints_controller.dart';
import '../widgets/complaints_card.dart';

class ComplaintsView extends GetView<ComplaintsController> {
  const ComplaintsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Complaints',
      body: Obx(() {
        if (c.complaints.isEmpty) {
          if (c.isLoading.value) return const _Loading();
          if (c.errorMessage.value != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load complaints',
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
                  icon: Icons.report_gmailerrorred_rounded,
                  value: '${c.total}',
                  label: 'Total Complaints',
                  color: AppColors.primary,
                ),
                StatCard(
                  icon: Icons.warning_amber_rounded,
                  value: '${c.openCount}',
                  label: 'Open Issues',
                  color: const Color(0xFFFACC15),
                ),
                StatCard(
                  icon: Icons.autorenew_rounded,
                  value: '${c.inProgressCount}',
                  label: 'In Progress',
                  color: AppColors.warning,
                ),
                StatCard(
                  icon: Icons.check_circle_rounded,
                  value: '${c.resolvedCount}',
                  label: 'Resolved',
                  color: AppColors.info,
                ),
              ],
            ),
            AppSizes.hMd,
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 200,
                child: PrimaryButton(
                    text: 'Create Complaint', onPressed: c.openCreate),
              ),
            ),
            AppSizes.hMd,
            SectionCard(
              title: 'Issues',
              child: Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  _IssueChip(
                    label: 'All',
                    selected: c.categoryFilter.value == null,
                    onTap: () => c.categoryFilter.value = null,
                  ),
                  ...ComplaintCategory.values.map((cat) => _IssueChip(
                    label: cat.label,
                    selected: c.categoryFilter.value == cat,
                    onTap: () => c.categoryFilter.value = cat,
                  )),
                ],
              ),
            ),
            AppSizes.hLg,
            MonthlyIncomeChart(
              points: c.categoryPoints,
              title: 'Complaints by Category',
              tooltipLabel: 'Complaints',
            ),
            AppSizes.hLg,
            Row(
              children: [
                Expanded(
                  child: _Filter<ComplaintStatus>(
                    hint: 'Status',
                    value: c.statusFilter.value,
                    items: {for (final s in ComplaintStatus.values) s: s.label},
                    onChanged: (v) => c.statusFilter.value = v,
                  ),
                ),
                AppSizes.wMd,
                Expanded(
                  child: _Filter<ComplaintPriority>(
                    hint: 'Priority',
                    value: c.priorityFilter.value,
                    items: {
                      for (final p in ComplaintPriority.values) p: p.label
                    },
                    onChanged: (v) => c.priorityFilter.value = v,
                  ),
                ),
              ],
            ),
            AppSizes.hMd,
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Center(child: Text('No complaints found')),
              )
            else
              ...list.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: ComplaintCard(
                  complaint: item,
                  onTap: () => c.showDetails(item),
                  onAction: (a) => c.onAction(item, a),
                ),
              )),
            AppSizes.hLg,
          ],
        );
      }),
    );
  }
}

class _IssueChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _IssueChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.black : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Text(
          label,
          style: AppTextStyles.smallRegular.copyWith(
              color: selected ? AppColors.white : Colors.black),
        ),
      ),
    );
  }
}

class _Filter<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const _Filter({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      value: value,
      isExpanded: true,
      isDense: true,
      hint: Text(hint, style: AppTextStyles.smallRegular),
      style: AppTextStyles.smallRegular.copyWith(color: Colors.black),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      items: [
        DropdownMenuItem<T?>(value: null, child: const Text('All')),
        ...items.entries.map(
                (e) => DropdownMenuItem<T?>(value: e.key, child: Text(e.value))),
      ],
      onChanged: onChanged,
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
        ShimmerLoader(height: 100, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 260, radius: AppSizes.radiusLg),
      ],
    );
  }
}