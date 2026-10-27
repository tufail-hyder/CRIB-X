import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constant/app_colors.dart';

/// Student Login / Sign up ki grey pill field (label nahi, hint andar)
class StudentAuthField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const StudentAuthField({
    super.key,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  State<StudentAuthField> createState() => _StudentAuthFieldState();
}

class _StudentAuthFieldState extends State<StudentAuthField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: 1.2),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF2B2B2B)),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFEEEEEE),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(const Color(0xFF0A1214)),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: const Color(0xFF6B7280),
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        )
            : null,
      ),
    );
  }
}

/// Neeche wala bara kaala button
class StudentAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const StudentAuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  static const dark = Color(0xFF0A1214);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: dark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: dark,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : Text(text),
      ),
    );
  }
}

/// "Don't have account. Sign up" jaisi line
class StudentAuthSwitchLine extends StatelessWidget {
  final String text;
  final String action;
  final VoidCallback onTap;
  const StudentAuthSwitchLine(
      {super.key, required this.text, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text('$text ',
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
        GestureDetector(
          onTap: onTap,
          child: Text(action,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111))),
        ),
      ],
    );
  }
}