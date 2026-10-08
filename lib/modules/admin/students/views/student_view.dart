import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/student_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/network_image.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../rooms/widgets/student_actions_menu.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/student_controllers.dart';
import '../widgets/payment_bridge.dart';

class StudentsView extends GetView<StudentsController> {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Students',
      body: Obx(() {
        if (c.students.isEmpty) {
          if (c.isLoading.value) return const _Loading();
          if (c.errorMessage.value != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load students',
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
                  icon: Icons.school_rounded,
                  value: '${c.totalStudents}',
                  label: 'Total Student',
                  color: AppColors.primary,
                ),
                StatCard(
                  icon: Icons.check_circle_rounded,
                  value: '${c.activeResidents}',
                  label: 'Active Residents',
                  color: const Color(0xFFFACC15),
                ),
                StatCard(
                  icon: Icons.receipt_long_rounded,
                  value: '${c.pendingPayments}',
                  label: 'Pending payments',
                  color: AppColors.warning,
                ),
                StatCard(
                  icon: Icons.login_rounded,
                  value: '${c.newCheckIns}',
                  label: 'New Check -in',
                  color: AppColors.info,
                ),
              ],
            ),
            AppSizes.hMd,
            Row(
              children: [
                Expanded(
                  child: _Filter<String>(
                    hint: 'Room No.',
                    value: c.roomFilter.value,
                    items: {
                      for (final r in c.rooms) r.id: 'Room ${r.roomNumber}'
                    },
                    onChanged: (v) => c.roomFilter.value = v,
                  ),
                ),
                AppSizes.wSm,
                Expanded(
                  child: _Filter<PaymentStatus>(
                    hint: 'Payment',
                    value: c.paymentFilter.value,
                    items: {for (final p in PaymentStatus.values) p: p.label},
                    onChanged: (v) => c.paymentFilter.value = v,
                  ),
                ),
                AppSizes.wSm,
                Expanded(
                  child: _Filter<StayStatus>(
                    hint: 'Stay',
                    value: c.stayFilter.value,
                    items: {for (final s in StayStatus.values) s: s.label},
                    onChanged: (v) => c.stayFilter.value = v,
                  ),
                ),
              ],
            ),
            AppSizes.hMd,
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 210,
                child: PrimaryButton(
                    text: 'Add New Student', onPressed: c.openAdd),
              ),
            ),
            AppSizes.hMd,
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
                    ...list.map((s) => _StudentRow(
                      student: s,
                      onAction: (a) => c.onAction(s, a),
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
        DropdownMenuItem<T?>(value: null, child: Text('All')),
        ...items.entries
            .map((e) => DropdownMenuItem<T?>(value: e.key, child: Text(e.value))),
      ],
      onChanged: onChanged,
    );
  }
}

class _StudentRow extends StatelessWidget {
  final StudentModel student;
  final ValueChanged<StudentAction> onAction;
  const _StudentRow({required this.student, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (rowContext) => InkWell(
        onTap: () => StudentActionsMenu.show(rowContext, onSelected: onAction),
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
                    if (!student.isActive)
                      Text('Left',
                          style: AppTextStyles.smallRegular
                              .copyWith(color: AppColors.gray600)),
                  ],
                ),
              ),
              PaymentBadge(status: student.paymentStatus),
            ],
          ),
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
        ShimmerLoader(height: 360, radius: AppSizes.radiusLg),
      ],
    );
  }
}