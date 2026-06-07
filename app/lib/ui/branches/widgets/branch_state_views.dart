import 'package:flutter/material.dart';

import '../branches_controller.dart';

class BranchLoadingView extends StatelessWidget {
  const BranchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando sucursales...'),
        ],
      ),
    );
  }
}

class BranchEmptyView extends StatelessWidget {
  const BranchEmptyView({required this.filter, super.key});

  final BranchFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      BranchFilter.all => 'No hay sucursales disponibles.',
      BranchFilter.active => 'No hay sucursales activas disponibles.',
      BranchFilter.inactive => 'No hay sucursales inactivas.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BranchStateIcon(icon: Icons.location_off_outlined),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BranchErrorView extends StatelessWidget {
  const BranchErrorView({
    required this.message,
    required this.detail,
    required this.onRetry,
    super.key,
  });

  final String message;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BranchStateIcon(icon: Icons.error_outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFA9B4BE), fontSize: 12),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}

class BranchStateIcon extends StatelessWidget {
  const BranchStateIcon({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Icon(icon, color: const Color(0xFF6F7C86), size: 30),
    );
  }
}
