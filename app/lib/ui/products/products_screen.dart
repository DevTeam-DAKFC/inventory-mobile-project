import 'package:flutter/material.dart';

import '../common/placeholder_module_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderModuleScreen(
      title: 'Productos',
      icon: Icons.inventory_2_outlined,
    );
  }
}
