import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;
  final Duration debounce;

  const CustomSearchBar({
    super.key,
    this.hint = 'Search',
    required this.onChanged,
    this.onFilterTap,
    this.controller,
    this.debounce = const Duration(milliseconds: 400),
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  Timer? _timer;

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value.trim()));
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.inputHeight,
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.oneLinerRegular,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search,
              size: AppSizes.iconMd, color: AppColors.inputIcon),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close,
                      size: AppSizes.iconMd, color: AppColors.inputIcon),
                  onPressed: _clear,
                ),
              if (widget.onFilterTap != null)
                IconButton(
                  icon: const Icon(Icons.tune_rounded,
                      size: AppSizes.iconMd, color: AppColors.inputIcon),
                  onPressed: widget.onFilterTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}