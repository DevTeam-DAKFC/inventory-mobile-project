import 'package:flutter/material.dart';

import '../common/placeholder_module_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderModuleScreen(
      title: 'History',
      icon: Icons.history_outlined,
    );
  }
}
