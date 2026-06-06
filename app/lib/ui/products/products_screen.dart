import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_session.dart';
import '../../navigation/routes.dart';
import '../common/placeholder_module_screen.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);

    return PlaceholderModuleScreen(
      title: 'Productos',
      icon: Icons.inventory_2_outlined,
      actions: [
        if (session.canViewAdminEntries)
          IconButton(
            tooltip: 'Importar CSV',
            onPressed: () => context.go(AppRoutes.productImport),
            icon: const Icon(Icons.upload_file),
          ),
      ],
    );
  }
}
