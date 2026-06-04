import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/routes.dart';
import '../common/placeholder_module_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderModuleScreen(
      title: 'Products',
      icon: Icons.inventory_2_outlined,
      actions: [
        IconButton(
          tooltip: 'Import products',
          onPressed: () => context.push(AppRoutes.productImport),
          icon: const Icon(Icons.upload_file),
        ),
      ],
    );
  }
}
