import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/room_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';

class BookingDraft {
  final RoomModel room;
  final String bed;
  final DateTime checkIn;
  final int months;
  const BookingDraft(this.room, this.bed, this.checkIn, this.months);
}

class BookingRequestSheet extends StatefulWidget {
  final String hostelName;
  final List<RoomModel> rooms;
  final Future<bool> Function(BookingDraft) onSubmit;

  const BookingRequestSheet({
    super.key,
    required this.hostelName,
    required this.rooms,
    required this.onSubmit,
  });

  @override
  State<BookingRequestSheet> createState() => _BookingRequestSheetState();
}

class _BookingRequestSheetState extends State<BookingRequestSheet> {
  static const _durations = [1, 2, 3, 6, 9, 12];

  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();

  String? _roomId;
  String? _bed;
  DateTime _checkIn = DateTime.now();
  int _months = 6;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = dateText(_checkIn);
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  RoomModel? get _room =>
      widget.rooms.firstWhereOrNull((r) => r.id == _roomId);

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn.isBefore(today) ? today : _checkIn,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _checkIn = picked;
      _dateCtrl.text = dateText(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final room = _room;
    final bed = _bed;
    if (room == null || bed == null) return;

    setState(() => _busy = true);
    final ok = await widget.onSubmit(BookingDraft(room, bed, _checkIn, _months));
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Get.back();
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: AppSizes.md, bottom: AppSizes.sm),
    child: Text(t, style: AppTextStyles.label),
  );

  @override
  Widget build(BuildContext context) {
    final room = _room;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Request to Book',
                          style: AppTextStyles.sectionInnerTitle),
                    ),
                    IconButton(
                        onPressed: Get.back, icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                Text(widget.hostelName,
                    style: AppTextStyles.smallRegular
                        .copyWith(color: AppColors.gray600)),
                _label('Room'),
                DropdownButtonFormField<String>(
                  value: _roomId,
                  isExpanded: true,
                  hint: const Text('Select room'),
                  style: AppTextStyles.oneLinerRegular
                      .copyWith(color: Colors.black),
                  items: widget.rooms
                      .map((r) => DropdownMenuItem(
                    value: r.id,
                    child: Text(
                      'Room ${r.roomNumber} · ${r.seater} seater · ${Formatters.currency(r.monthlyPrice)}/mo',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _roomId = v;
                    _bed = null;
                  }),
                  validator: (v) => v == null ? 'Select a room' : null,
                ),
                _label('Bed'),
                DropdownButtonFormField<String>(
                  key: ValueKey(_roomId),
                  value: _bed,
                  isExpanded: true,
                  hint: const Text('Select bed'),
                  style: AppTextStyles.oneLinerRegular
                      .copyWith(color: Colors.black),
                  items: (room?.freeBedLabels ?? const <String>[])
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setState(() => _bed = v),
                  validator: (v) => v == null ? 'Select a bed' : null,
                ),
                _label('Check in Date'),
                CustomTextField(
                  controller: _dateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  suffix: const Icon(Icons.calendar_today_outlined,
                      size: AppSizes.iconMd, color: AppColors.inputIcon),
                ),
                _label('Duration'),
                DropdownButtonFormField<int>(
                  value: _months,
                  isExpanded: true,
                  style: AppTextStyles.oneLinerRegular
                      .copyWith(color: Colors.black),
                  items: _durations
                      .map((m) => DropdownMenuItem(
                      value: m, child: Text('$m month${m == 1 ? '' : 's'}')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _months = v);
                  },
                ),
                AppSizes.hMd,
                Text(
                  'The hostel owner will review your request. Your bed is confirmed once it is approved.',
                  style: AppTextStyles.smallRegular
                      .copyWith(color: AppColors.gray600),
                ),
                AppSizes.hLg,
                PrimaryButton(
                  text: 'Send Request',
                  isLoading: _busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}