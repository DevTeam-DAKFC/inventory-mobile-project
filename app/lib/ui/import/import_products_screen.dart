import 'package:flutter/material.dart';

import '../common/placeholder_module_screen.dart';

class ImportProductsScreen extends StatelessWidget {
  const ImportProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderModuleScreen(
      title: 'Import products',
      icon: Icons.upload_file,
    );
  }
}
