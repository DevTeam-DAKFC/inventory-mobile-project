import 'package:flutter/material.dart';

import '../common/placeholder_module_screen.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderModuleScreen(
      title: 'Stock',
      icon: Icons.store_outlined,
    );
  }
}
