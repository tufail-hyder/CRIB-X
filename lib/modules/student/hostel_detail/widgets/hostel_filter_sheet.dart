import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/hostel_filter.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';

class HostelFilterSheet extends StatefulWidget {
  final HostelFilter initial;
  final List<String> cities;
  final List<String> amenityOptions;
  final ValueChanged<HostelFilter> onApply;

  const HostelFilterSheet({
    super.key,
    required this.initial,
    required this.cities,
    required this.amenityOptions,
    required this.onApply,
  });

  @override
  State<HostelFilterSheet> createState() => _HostelFilterSheetState();
}

class _HostelFilterSheetState extends State<HostelFilterSheet> {
  static const _roomTypes = {1: 'Single', 2: 'Double', 3: 'Triple'};

  late String? _city =
  widget.cities.contains(widget.initial.city) ? widget.initial.city : null;
  late final _minCtrl = TextEditingController(
      text: widget.initial.minPrice?.toStringAsFixed(0) ?? '');
  late final _maxCtrl = TextEditingController(
      text: widget.initial.maxPrice?.toStringAsFixed(0) ?? '');
  late final Set<int> _types = {...widget.initial.roomTypes};
  late final Set<HostelGender> _genders = {...widget.initial.genders};
  late final Set<String> _amenities = {...widget.initial.amenities};

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _toggle<T>(Set<T> set, T v) =>
      setState(() => set.contains(v) ? set.remove(v) : set.add(v));

  void _apply() {
    final min = double.tryParse(_minCtrl.text.trim());
    final max = double.tryParse(_maxCtrl.text.trim());
    if (min != null && max != null && min > max) {
      AppSnackbar.warning('Minimum price cannot be more than maximum.');
      return;
    }
    widget.onApply(HostelFilter(
      city: _city,
      minPrice: min,
      maxPrice: max,
      roomTypes: _types,
      genders: _genders,
      amenities: _amenities,
    ));
    Get.back();
  }

  void _reset() {
    widget.onApply(const HostelFilter());
    Get.back();
  }

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(top: AppSizes.lg, bottom: AppSizes.sm),
    child: Text(t, style: AppTextStyles.label),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Search & Filters',
                        style: AppTextStyles.sectionInnerTitle),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              _title('City'),
              DropdownButtonFormField<String?>(
                value: _city,
                isExpanded: true,
                style: AppTextStyles.oneLinerRegular
                    .copyWith(color: Colors.black),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('All cities')),
                  ...widget.cities.map((c) =>
                      DropdownMenuItem<String?>(value: c, child: Text(c))),
                ],
                onChanged: (v) => setState(() => _city = v),
              ),
              _title('Price Range (per month)'),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      hint: 'Min',
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('to'),
                  ),
                  Expanded(
                    child: CustomTextField(
                      hint: 'Max',
                      controller: _maxCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              _title('Room Type'),
              Wrap(
                spacing: AppSizes.lg,
                runSpacing: AppSizes.sm,
                children: _roomTypes.entries
                    .map((e) => _Check(
                  label: e.value,
                  checked: _types.contains(e.key),
                  onTap: () => _toggle(_types, e.key),
                ))
                    .toList(),
              ),
              _title('Gender'),
              Wrap(
                spacing: AppSizes.lg,
                runSpacing: AppSizes.sm,
                children: HostelGender.values
                    .map((g) => _Check(
                  label: g.label,
                  checked: _genders.contains(g),
                  onTap: () => _toggle(_genders, g),
                ))
                    .toList(),
              ),
              if (widget.amenityOptions.isNotEmpty) ...[
                _title('Amenities'),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: widget.amenityOptions
                      .map((a) => _AmenityChip(
                    label: a,
                    selected: _amenities.contains(a),
                    onTap: () => _toggle(_amenities, a),
                  ))
                      .toList(),
                ),
              ],
              const SizedBox(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                        text: 'Reset', isOutlined: true, onPressed: _reset),
                  ),
                  AppSizes.wMd,
                  Expanded(
                    child: PrimaryButton(text: 'Apply Filters', onPressed: _apply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;
  const _Check(
      {required this.label, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
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
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AmenityChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Text(
          label,
          style: AppTextStyles.smallRegular
              .copyWith(color: selected ? AppColors.white : Colors.black),
        ),
      ),
    );
  }
}