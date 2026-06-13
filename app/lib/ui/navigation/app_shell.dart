import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Column(
            children: [
              Expanded(child: navigationShell),
              _BottomNavigation(
                selectedIndex: navigationShell.currentIndex,
                onSelected: _onDestinationSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    _BottomNavigationItem(_LucideIconType.home, 'Inicio'),
    _BottomNavigationItem(_LucideIconType.package, 'Productos'),
    _BottomNavigationItem(_LucideIconType.layers, 'Stock'),
    _BottomNavigationItem(_LucideIconType.trendingUp, 'Movimientos'),
    _BottomNavigationItem(_LucideIconType.bell, 'Alertas'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF12181C),
        border: Border(top: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var index = 0; index < _items.length; index++)
                Expanded(
                  child: _BottomNavigationButton(
                    item: _items[index],
                    active: selectedIndex == index,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationButton extends StatelessWidget {
  const _BottomNavigationButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _BottomNavigationItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF14B8A6) : const Color(0xFF6F7C86);

    return Semantics(
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LucideNavIcon(
              type: item.icon,
              color: color,
              strokeWidth: active ? 2.5 : 2,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigationItem {
  const _BottomNavigationItem(this.icon, this.label);

  final _LucideIconType icon;
  final String label;
}

enum _LucideIconType { home, package, layers, trendingUp, bell }

class _LucideNavIcon extends StatelessWidget {
  const _LucideNavIcon({
    required this.type,
    required this.color,
    required this.strokeWidth,
  });

  final _LucideIconType type;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(20),
      painter: _LucideIconPainter(
        type: type,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _LucideIconPainter extends CustomPainter {
  const _LucideIconPainter({
    required this.type,
    required this.color,
    required this.strokeWidth,
  });

  final _LucideIconType type;
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

    switch (type) {
      case _LucideIconType.home:
        _paintHome(canvas, paint);
      case _LucideIconType.package:
        _paintPackage(canvas, paint);
      case _LucideIconType.layers:
        _paintLayers(canvas, paint);
      case _LucideIconType.trendingUp:
        _paintTrendingUp(canvas, paint);
      case _LucideIconType.bell:
        _paintBell(canvas, paint);
    }
  }

  void _paintHome(Canvas canvas, Paint paint) {
    final body = Path()
      ..moveTo(15, 21)
      ..lineTo(15, 13)
      ..quadraticBezierTo(15, 12, 14, 12)
      ..lineTo(10, 12)
      ..quadraticBezierTo(9, 12, 9, 13)
      ..lineTo(9, 21)
      ..moveTo(3, 10)
      ..quadraticBezierTo(3, 9, 3.7, 8.5)
      ..lineTo(10.7, 2.5)
      ..quadraticBezierTo(12, 1.5, 13.3, 2.5)
      ..lineTo(20.3, 8.5)
      ..quadraticBezierTo(21, 9, 21, 10)
      ..lineTo(21, 19)
      ..quadraticBezierTo(21, 21, 19, 21)
      ..lineTo(5, 21)
      ..quadraticBezierTo(3, 21, 3, 19)
      ..close();
    canvas.drawPath(body, paint);
  }

  void _paintPackage(Canvas canvas, Paint paint) {
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

  void _paintLayers(Canvas canvas, Paint paint) {
    final first = Path()
      ..moveTo(12, 2)
      ..lineTo(21, 7)
      ..lineTo(12, 12)
      ..lineTo(3, 7)
      ..close();
    final second = Path()
      ..moveTo(3, 12)
      ..lineTo(12, 17)
      ..lineTo(21, 12);
    final third = Path()
      ..moveTo(3, 17)
      ..lineTo(12, 22)
      ..lineTo(21, 17);
    canvas.drawPath(first, paint);
    canvas.drawPath(second, paint);
    canvas.drawPath(third, paint);
  }

  void _paintTrendingUp(Canvas canvas, Paint paint) {
    final line = Path()
      ..moveTo(3, 17)
      ..lineTo(9, 11)
      ..lineTo(13, 15)
      ..lineTo(21, 7);
    final arrow = Path()
      ..moveTo(14, 7)
      ..lineTo(21, 7)
      ..lineTo(21, 14);
    canvas.drawPath(line, paint);
    canvas.drawPath(arrow, paint);
  }

  void _paintBell(Canvas canvas, Paint paint) {
    final bell = Path()
      ..moveTo(10.3, 21)
      ..quadraticBezierTo(12, 22, 13.7, 21)
      ..moveTo(18, 8)
      ..quadraticBezierTo(18, 5.5, 16.2, 3.8)
      ..quadraticBezierTo(14.5, 2, 12, 2)
      ..quadraticBezierTo(9.5, 2, 7.8, 3.8)
      ..quadraticBezierTo(6, 5.5, 6, 8)
      ..quadraticBezierTo(6, 13, 4, 17)
      ..lineTo(20, 17)
      ..quadraticBezierTo(18, 13, 18, 8);
    canvas.drawPath(bell, paint);
  }

  @override
  bool shouldRepaint(_LucideIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
