import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  static const Color _accent = Color(0xFF14B8A6);
  static const Color _onAccent = Color(0xFF0C1013);
  static const Color _disabledBg = Color(0xFF1F2A30);
  static const Color _disabledFg = Color(0xFF6F7C86);

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;
    final background = disabled ? _disabledBg : _accent;
    final foreground = disabled ? _disabledFg : _onAccent;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          onTap: disabled ? null : onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
