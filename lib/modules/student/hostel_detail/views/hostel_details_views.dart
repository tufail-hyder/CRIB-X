import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/network_image.dart';
import '../../widegts/hostel_card.dart';
import '../../widegts/hostel_listing.dart';
import '../../widegts/student_scaffold.dart';
import '../controllers/hostel_details_controllers.dart';

class HostelDetailsView extends StatelessWidget {
  const HostelDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args is! HostelDetailsArgs) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hostel Details')),
        body: const EmptyState(
          icon: Icons.apartment_rounded,
          title: 'Hostel not found',
          message: 'Please go back and try again.',
        ),
      );
    }
    return _Body(args: args);
  }
}
class _Body extends StatefulWidget {
  final HostelDetailsArgs args;
  const _Body({required this.args});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final String _tag =
      '${widget.args.listing.hostel.id}-${DateTime.now().microsecondsSinceEpoch}';

  late final HostelDetailsController c = Get.put(
    HostelDetailsController(
        Get.find(), Get.find(), Get.find(), widget.args.listing, widget.args.all),
    tag: _tag,
  );

  @override
  void dispose() {
    Get.delete<HostelDetailsController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = c.hostel;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding, AppSizes.md, AppSizes.screenPadding, 0),
              child: Row(
                children: [
                  StudentHeaderIcon(
                      icon: Icons.arrow_back_rounded, onTap: Get.back),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Hostel Details',
                        style: AppTextStyles.screenTitle.copyWith(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                  ),
                  StudentHeaderIcon(
                      icon: Icons.notifications_none_rounded,
                      onTap: c.openNotifications),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                children: [
                  _Gallery(c: c),
                  AppSizes.hLg,
                  Text('Hostel Information',
                      style: AppTextStyles.sectionInnerTitle),
                  AppSizes.hMd,
                  Text(h.name,
                      style: AppTextStyles.screenTitle
                          .copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
                  AppSizes.hSm,
                  Obx(() {
                    final price = c.displayPrice;
                    return Row(
                      children: [
                        Text('Monthly Rent', style: AppTextStyles.smallRegular),
                        const Spacer(),
                        Text(
                          price == null ? 'Price not set' : Formatters.currency(price),
                          style: AppTextStyles.oneLinerSemiBold.copyWith(
                              color: AppColors.primary, fontSize: 18),
                        ),
                      ],
                    );
                  }),
                  AppSizes.hSm,
                  if ([h.city, h.address].any((e) => e.trim().isNotEmpty))
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [h.city, h.address]
                                .where((e) => e.trim().isNotEmpty)
                                .join(', '),
                            style: AppTextStyles.smallRegular,
                          ),
                        ),
                      ],
                    ),
                  AppSizes.hSm,
                  Obx(() => Row(
                    children: [
                      const Icon(Icons.bed_rounded, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        c.isLoadingRooms.value
                            ? 'Checking beds...'
                            : '${c.availableBeds} ${c.availableBeds == 1 ? 'bed' : 'beds'} available',
                        style: AppTextStyles.smallRegular,
                      ),
                    ],
                  )),
                  const _Gap(),
                  Text('Description', style: AppTextStyles.sectionInnerTitle),
                  AppSizes.hSm,
                  Text(
                    h.description.trim().isEmpty
                        ? 'No description added yet.'
                        : h.description,
                    style: AppTextStyles.body,
                  ),
                  const _Gap(),
                  Text('Gender', style: AppTextStyles.sectionInnerTitle),
                  AppSizes.hSm,
                  Wrap(
                    spacing: AppSizes.lg,
                    runSpacing: AppSizes.sm,
                    children: HostelGender.values
                        .map((g) => _ReadOnlyCheck(
                        label: g.label, checked: h.gender == g))
                        .toList(),
                  ),
                  const _Gap(),
                  Text('Room Type', style: AppTextStyles.sectionInnerTitle),
                  AppSizes.hSm,
                  Obx(() => Wrap(
                    spacing: AppSizes.lg,
                    runSpacing: AppSizes.sm,
                    children: {1: 'Single', 2: 'Double', 3: 'Triple'}
                        .entries
                        .map((e) => _ReadOnlyCheck(
                        label: e.value, checked: c.hasRoomType(e.key)))
                        .toList(),
                  )),
                  const _Gap(),
                  Text('Amenities', style: AppTextStyles.sectionInnerTitle),
                  AppSizes.hSm,
                  if (h.amenities.isEmpty)
                    Text('No amenities listed.',
                        style: AppTextStyles.smallRegular
                            .copyWith(color: AppColors.gray600))
                  else
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: h.amenities
                          .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: Text(a, style: AppTextStyles.smallRegular),
                      ))
                          .toList(),
                    ),
                  AppSizes.hLg,
                  Obx(() => PrimaryButton(
                    text: 'Book Now',
                    isLoading: c.isRequesting.value,
                    onPressed: c.startBooking,
                  )),
                  const _Gap(),
                  if (c.related.isNotEmpty) ...[
                    Text('Related Hostel',
                        style: AppTextStyles.sectionInnerTitle),
                    AppSizes.hMd,
                    ...c.related.map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.lg),
                      child: Obx(() => HostelCard(
                        listing: l,
                        isFavorite: c.favorites.contains(l.hostel.id),
                        onFavorite: () => c.toggleFavorite(l.hostel.id),
                        onView: () => c.openRelated(l),
                      )),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  final HostelDetailsController c;
  const _Gallery({required this.c});

  @override
  Widget build(BuildContext context) {
    final images = c.hostel.images;

    return Obx(() {
      final selected = c.selectedImage.value;
      final index =
      images.isEmpty ? 0 : selected.clamp(0, images.length - 1).toInt();

      return Column(
        children: [
          AppNetworkImage(
            url: images.isEmpty ? null : images[index],
            width: double.infinity,
            height: 210,
            radius: AppSizes.radiusMd,
          ),
          if (images.length > 1) ...[
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => c.selectedImage.value = i,
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: i == index ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: AppNetworkImage(
                      url: images[i],
                      width: 80,
                      height: 56,
                      radius: AppSizes.radiusMd - 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _ReadOnlyCheck extends StatelessWidget {
  final String label;
  final bool checked;
  const _ReadOnlyCheck({required this.label, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          size: 20,
          color: checked ? Colors.black : AppColors.gray400,
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.smallRegular),
      ],
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: AppSizes.xl);
}