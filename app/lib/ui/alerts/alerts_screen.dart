import 'package:flutter/material.dart';

import '../common/placeholder_module_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderModuleScreen(
      title: 'Alertas',
      icon: Icons.notifications_outlined,
    );
  }
}
