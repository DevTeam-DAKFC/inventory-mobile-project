import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/logout_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0D0F), Color(0xFF111A20)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(children: [_DashboardHeader(), _DashboardContent()]),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggingOut = ref.watch(logoutControllerProvider).isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF12181C),
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Color(0xFF14B8A6), shape: BoxShape.circle),
                child: const Center(
                  child: Text(
                    'UI',
                    style: TextStyle(
                      color: Color(0xFF0C1013),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inventario', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14)),
                    SizedBox(height: 2),
                    Text(
                      'Panel principal',
                      style: TextStyle(color: Color(0xFF6F7C86), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_outlined, color: Color(0xFFA9B4BE), size: 20),
                    Positioned(
                      top: 9,
                      right: 9,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                        child: SizedBox(width: 8, height: 8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  tooltip: 'Cerrar sesión',
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                  onPressed: isLoggingOut
                      ? null
                      : () => ref.read(logoutControllerProvider.notifier).logout(),
                  icon: isLoggingOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA9B4BE)),
                          ),
                        )
                      : const Icon(Icons.logout, color: Color(0xFFA9B4BE), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2A30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0x0FFFFFFF)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sucursal activa', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14)),
                SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down, color: Color(0xFF6F7C86), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _HeroCard(),
          SizedBox(height: 20),
          _KpiGrid(),
          SizedBox(height: 20),
          _QuickActions(),
          SizedBox(height: 20),
          _RecentMovements(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return const _PrototypeCard(
      padding: EdgeInsets.all(16),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Badge(text: 'Stock visibility'),
                    SizedBox(height: 8),
                    Text(
                      'Resumen de inventario',
                      style: TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Datos reales pendientes de conectar',
                      style: TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Disponibilidad', style: TextStyle(color: Color(0xFFA9B4BE), fontSize: 12)),
              Text('75%', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 12)),
            ],
          ),
          SizedBox(height: 6),
          _ProgressBar(value: 0.75),
          SizedBox(height: 12),
          Row(
            children: [
              Text('Ver resumen', style: TextStyle(color: Color(0xFF14B8A6), fontSize: 12)),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward, size: 14, color: Color(0xFF14B8A6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid();

  static const _items = [
    _KpiItem('Productos activos', '-', _DashboardIconType.package, Color(0xFF14B8A6)),
    _KpiItem('Stock bajo', '-', _DashboardIconType.alertTriangle, Color(0xFFF59E0B)),
    _KpiItem('Agotados', '-', _DashboardIconType.xCircle, Color(0xFFEF4444)),
    _KpiItem('Movimientos hoy', '-', _DashboardIconType.trendingUp, Color(0xFF3B82F6)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.35,
      ),
      itemBuilder: (context, index) => _KpiCard(item: _items[index]),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});

  final _KpiItem item;

  @override
  Widget build(BuildContext context) {
    return _PrototypeCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2A30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _DashboardIcon(type: item.icon, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const _items = [
    _ActionItem('Nuevo producto', _DashboardIconType.package),
    _ActionItem('Registrar entrada', _DashboardIconType.plus),
    _ActionItem('Registrar salida', _DashboardIconType.trendingUp),
    _ActionItem('Ver historial', _DashboardIconType.trendingUp),
    _ActionItem('Sucursales', _DashboardIconType.package),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 10),
          child: Text('Acciones rápidas', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.15,
          ),
          itemBuilder: (context, index) => _ActionButton(item: _items[index]),
        ),
        const SizedBox(height: 8),
        _ActionButton(item: _items[4], centered: true),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.item, this.centered = false});

  final _ActionItem item;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF12181C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Row(
        mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          _DashboardIcon(type: item.icon, color: const Color(0xFF14B8A6)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentMovements extends StatelessWidget {
  const _RecentMovements();

  static const _items = [
    _MovementItem('Salida', 'Movimiento pendiente', '-', '-', 'Sucursal', 'Usuario', 'Fecha'),
    _MovementItem('Salida', 'Movimiento pendiente', '-', '-', 'Sucursal', 'Usuario', 'Fecha'),
    _MovementItem('Entrada', 'Movimiento pendiente', '-', '-', 'Sucursal', 'Usuario', 'Fecha'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Últimos movimientos', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 14)),
            Text('Ver todos', style: TextStyle(color: Color(0xFF14B8A6), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in _items) ...[_MovementCard(item: item), const SizedBox(height: 8)],
      ],
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({required this.item});

  final _MovementItem item;

  @override
  Widget build(BuildContext context) {
    final incoming = item.type == 'Entrada';

    return _PrototypeCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Badge(
                text: item.type,
                variant: incoming ? _BadgeVariant.success : _BadgeVariant.info,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.product,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.branch, style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 10)),
              Text(
                '${item.quantity} → Stock: ${item.stock}',
                style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.user, style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 10)),
              Text(item.date, style: const TextStyle(color: Color(0xFF6F7C86), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrototypeCard extends StatelessWidget {
  const _PrototypeCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: elevated ? const Color(0xFF182126) : const Color(0xFF12181C),
        gradient: elevated
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF182126), Color(0xFF1F2A30)],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.variant = _BadgeVariant.defaultVariant});

  final String text;
  final _BadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = switch (variant) {
      _BadgeVariant.success => (
        const Color(0x2422C55E),
        const Color(0xFF22C55E),
        const Color(0x3322C55E),
      ),
      _BadgeVariant.info => (
        const Color(0x243B82F6),
        const Color(0xFF3B82F6),
        const Color(0x333B82F6),
      ),
      _BadgeVariant.defaultVariant => (
        const Color(0x2414B8A6),
        const Color(0xFF14B8A6),
        const Color(0x5214B8A6),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.$3),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: colors.$2,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: const Color(0xFF12181C),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
      ),
    );
  }
}

enum _BadgeVariant { success, info, defaultVariant }

class _KpiItem {
  const _KpiItem(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final _DashboardIconType icon;
  final Color color;
}

class _ActionItem {
  const _ActionItem(this.label, this.icon);

  final String label;
  final _DashboardIconType icon;
}

class _MovementItem {
  const _MovementItem(
    this.type,
    this.product,
    this.quantity,
    this.stock,
    this.branch,
    this.user,
    this.date,
  );

  final String type;
  final String product;
  final String quantity;
  final String stock;
  final String branch;
  final String user;
  final String date;
}

enum _DashboardIconType { package, alertTriangle, xCircle, trendingUp, plus }

class _DashboardIcon extends StatelessWidget {
  const _DashboardIcon({required this.type, required this.color});

  final _DashboardIconType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(16),
      painter: _DashboardIconPainter(type: type, color: color),
    );
  }
}

class _DashboardIconPainter extends CustomPainter {
  const _DashboardIconPainter({required this.type, required this.color});

  final _DashboardIconType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case _DashboardIconType.package:
        _paintPackage(canvas, paint);
      case _DashboardIconType.alertTriangle:
        _paintAlertTriangle(canvas, paint);
      case _DashboardIconType.xCircle:
        _paintXCircle(canvas, paint);
      case _DashboardIconType.trendingUp:
        _paintTrendingUp(canvas, paint);
      case _DashboardIconType.plus:
        _paintPlus(canvas, paint);
    }
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

  void _paintAlertTriangle(Canvas canvas, Paint paint) {
    final triangle = Path()
      ..moveTo(10.3, 3.9)
      ..quadraticBezierTo(12, 1.2, 13.7, 3.9)
      ..lineTo(22, 18)
      ..quadraticBezierTo(23.3, 20.5, 20.5, 20.5)
      ..lineTo(3.5, 20.5)
      ..quadraticBezierTo(0.7, 20.5, 2, 18)
      ..close();
    canvas.drawPath(triangle, paint);

    canvas.drawLine(const Offset(12, 9), const Offset(12, 13), paint);
    canvas.drawCircle(const Offset(12, 17), 0.4, paint);
  }

  void _paintXCircle(Canvas canvas, Paint paint) {
    canvas.drawCircle(const Offset(12, 12), 10, paint);
    canvas.drawLine(const Offset(15, 9), const Offset(9, 15), paint);
    canvas.drawLine(const Offset(9, 9), const Offset(15, 15), paint);
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

  void _paintPlus(Canvas canvas, Paint paint) {
    canvas.drawLine(const Offset(12, 5), const Offset(12, 19), paint);
    canvas.drawLine(const Offset(5, 12), const Offset(19, 12), paint);
  }

  @override
  bool shouldRepaint(_DashboardIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
