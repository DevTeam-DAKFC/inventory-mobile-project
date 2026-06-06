import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  static const Color _fill = Color(0xFF141B20);
  static const Color _border = Color(0x12FFFFFF);
  static const Color _textPrimary = Color(0xFFF8FAFC);
  static const Color _textSecondary = Color(0xFFA9B4BE);
  static const Color _textMuted = Color(0xFF6F7C86);
  static const Color _danger = Color(0xFFEF4444);
  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: enabled,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          style: const TextStyle(color: _textPrimary, fontSize: 15, height: 1.4),
          cursorColor: const Color(0xFF14B8A6),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _fill,
            hintText: hintText,
            hintStyle: const TextStyle(color: _textMuted, fontSize: 15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            border: _outline(_border),
            enabledBorder: _outline(_border),
            focusedBorder: _outline(const Color(0xFF14B8A6), width: 1.4),
            errorBorder: _outline(_danger),
            focusedErrorBorder: _outline(_danger, width: 1.4),
            disabledBorder: _outline(_border),
            errorStyle: const TextStyle(color: _danger, fontSize: 12, height: 1.3),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _outline(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(_radius)),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
