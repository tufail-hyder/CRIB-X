import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/section_card.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_action_menu.dart';
import '../widgets/booking_badge.dart';

class BookingsView extends GetView<BookingsController> {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Bookings',
      body: Obx(() {
        if (c.bookings.isEmpty) {
          if (c.isLoading.value) return const _Loading();
          if (c.errorMessage.value != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load bookings',
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
                  icon: Icons.book_online_rounded,
                  value: '${c.totalBookings}',
                  label: 'Total Bookings',
                  color: AppColors.primary,
                ),
                StatCard(
                  icon: Icons.hourglass_top_rounded,
                  value: '${c.pendingRequests}',
                  label: 'Pending Request',
                  color: const Color(0xFFFACC15),
                ),
                StatCard(
                  icon: Icons.check_circle_rounded,
                  value: '${c.approvedBookings}',
                  label: 'Approved Bookings',
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
                  child: _Filter<BookingStatus>(
                    hint: 'Status',
                    value: c.statusFilter.value,
                    items: {for (final s in BookingStatus.values) s: s.label},
                    onChanged: (v) => c.statusFilter.value = v,
                  ),
                ),
                AppSizes.wSm,
                Expanded(
                  child: _Filter<int>(
                    hint: 'Room Type',
                    value: c.seaterFilter.value,
                    items: {
                      for (final s in BookingsController.seaterOptions)
                        s: '$s seater'
                    },
                    onChanged: (v) => c.seaterFilter.value = v,
                  ),
                ),
                AppSizes.wSm,
                Expanded(
                  child: _DateFilter(
                    value: c.dateFilter.value,
                    onTap: c.pickDateFilter,
                    onClear: c.clearDateFilter,
                  ),
                ),
              ],
            ),
            AppSizes.hMd,
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 190,
                child:
                PrimaryButton(text: 'Create Booking', onPressed: c.openCreate),
              ),
            ),
            AppSizes.hMd,
            SectionCard(
              title: 'Bookings',
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Student', style: AppTextStyles.label),
                        Text('Booking', style: AppTextStyles.label),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSizes.xl),
                      child: Text('No bookings found'),
                    )
                  else
                    ...list.map((b) => _BookingRow(
                      booking: b,
                      onAction: (a) => c.onAction(b, a),
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
        DropdownMenuItem<T?>(value: null, child: const Text('All')),
        ...items.entries.map(
                (e) => DropdownMenuItem<T?>(value: e.key, child: Text(e.value))),
      ],
      onChanged: onChanged,
    );
  }
}

class _DateFilter extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const _DateFilter(
      {required this.value, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? 'Check-in' : dateText(value!),
                style: AppTextStyles.smallRegular,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value == null)
              const Icon(Icons.calendar_today_outlined, size: 14)
            else
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final BookingModel booking;
  final ValueChanged<BookingAction> onAction;
  const _BookingRow({required this.booking, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final initial = booking.studentName.isEmpty
        ? '?'
        : booking.studentName[0].toUpperCase();

    return Builder(
      builder: (rowContext) => InkWell(
        onTap: () =>
            BookingActionsMenu.show(rowContext, onSelected: onAction),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.gray100,
                child: Text(initial, style: AppTextStyles.smallSemiBold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.studentName,
                        style: AppTextStyles.smallRegular,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      'Room ${booking.roomNumber} · ${booking.bed} · ${dateText(booking.checkInDate)}',
                      style: AppTextStyles.smallRegular
                          .copyWith(color: AppColors.gray600, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              BookingBadge(status: booking.status),
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