import 'package:flutter/material.dart';

class AuthPackageMark extends StatelessWidget {
  const AuthPackageMark({
    super.key,
    this.size = 32,
    this.color = const Color(0xFF14B8A6),
    this.strokeWidth = 2,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LucidePackagePainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _LucidePackagePainter extends CustomPainter {
  const _LucidePackagePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final box = Path()
      ..moveTo(11, 21.7)
      ..quadraticBezierTo(12, 22.3, 13, 21.7)
      ..lineTo(20, 17.7)
      ..quadraticBezierTo(21, 17.1, 21, 16)
      ..lineTo(21, 8)
      ..quadraticBezierTo(21, 6.9, 20, 6.3)
      ..lineTo(13, 2.3)
      ..quadraticBezierTo(12, 1.7, 11, 2.3)
      ..lineTo(4, 6.3)
      ..quadraticBezierTo(3, 6.9, 3, 8)
      ..lineTo(3, 16)
      ..quadraticBezierTo(3, 17.1, 4, 17.7)
      ..close();
    canvas.drawPath(box, paint);

    final lines = Path()
      ..moveTo(12, 22)
      ..lineTo(12, 12)
      ..moveTo(3.3, 7)
      ..lineTo(12, 12)
      ..lineTo(20.7, 7)
      ..moveTo(7.5, 4.3)
      ..lineTo(16.5, 9.7);
    canvas.drawPath(lines, paint);
  }

  @override
  bool shouldRepaint(_LucidePackagePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
