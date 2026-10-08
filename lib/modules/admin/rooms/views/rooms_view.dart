import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../widgets/admin_scaffold.dart';
import '../controllers/rooms_controller.dart';
import '../widgets/room_card.dart';

class RoomsView extends GetView<RoomsController> {
  const RoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return AdminScaffold(
      title: 'Rooms and bed',
      body: Obx(() {
        if (c.rooms.isEmpty) {
          if (c.isLoading.value) return const _Loading();
          if (c.errorMessage.value != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load rooms',
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
                  icon: Icons.meeting_room_rounded,
                  value: '${c.totalRooms}',
                  label: 'Total Rooms',
                  color: AppColors.primary,
                ),
                StatCard(
                  icon: Icons.bed_rounded,
                  value: '${c.occupiedBeds}',
                  label: 'Occupied Beds',
                  color: const Color(0xFFFACC15),
                ),
                StatCard(
                  icon: Icons.receipt_long_rounded,
                  value: '${c.pendingPayments}',
                  label: 'Pending payments',
                  color: AppColors.warning,
                ),
                StatCard(
                  icon: Icons.bed_outlined,
                  value: '${c.availableBeds}',
                  label: 'Available Beds',
                  color: AppColors.info,
                ),
              ],
            ),
            AppSizes.hMd,
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int?>(
                    value: c.seaterFilter.value,
                    isExpanded: true,
                    style: AppTextStyles.oneLinerRegular,
                    decoration: const InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text('Room Types: All')),
                      ...RoomsController.seaterOptions.map((s) =>
                          DropdownMenuItem<int?>(
                              value: s, child: Text('$s seater'))),
                    ],
                    onChanged: (v) => c.seaterFilter.value = v,
                  ),
                ),
                AppSizes.wMd,
                Expanded(
                  flex: 2,
                  child: PrimaryButton(text: 'Add Room', onPressed: c.openAdd),
                ),
              ],
            ),
            AppSizes.hMd,
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppSizes.xl),
                child: EmptyState(
                  icon: Icons.meeting_room_outlined,
                  title: 'No rooms found',
                  message: 'Tap "Add Room" to create a room.',
                ),
              )
            else
              ...list.map((room) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: RoomCard(room: room, onAction: (a) => c.onAction(room, a)),
              )),
          ],
        );
      }),
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
        ShimmerLoader(height: 200, radius: AppSizes.radiusLg),
        AppSizes.hLg,
        ShimmerLoader(height: 200, radius: AppSizes.radiusLg),
      ],
    );
  }
}