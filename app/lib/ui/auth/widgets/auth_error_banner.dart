import 'package:flutter/material.dart';

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String? message;

  static const Color _danger = Color(0xFFEF4444);
  static const Color _backgroundColor = Color(0x24EF4444);
  static const Color _borderColor = Color(0x33EF4444);

  @override
  Widget build(BuildContext context) {
    final value = message;
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: _borderColor),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _danger, fontSize: 14, height: 1.4),
      ),
    );
  }
}
