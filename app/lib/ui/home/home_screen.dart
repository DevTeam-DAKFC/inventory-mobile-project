import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_session.dart';
import '../../navigation/routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Inventory overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _HomeActionCard(
              icon: Icons.swap_vert,
              title: 'Register movement',
              subtitle: 'Create an incoming or outgoing stock movement.',
              onTap: () => context.push(AppRoutes.movementNew),
            ),
            const SizedBox(height: 12),
            _HomeActionCard(
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              subtitle: 'Open the product catalog section.',
              onTap: () => context.go(AppRoutes.products),
            ),
            const SizedBox(height: 12),
            if (ref.read(appSessionProvider).canViewAdminEntries) ...[
              _HomeActionCard(
                icon: Icons.upload_file,
                title: 'Import products',
                subtitle: 'Open the CSV import entry point.',
                onTap: () => context.push(AppRoutes.productImport),
              ),
              const SizedBox(height: 12),
            ],
            _HomeActionCard(
              icon: Icons.logout,
              title: 'Sign out',
              subtitle: 'Return to the public auth flow.',
              onTap: () => ref.read(appSessionProvider).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
