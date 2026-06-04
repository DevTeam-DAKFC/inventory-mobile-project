import 'package:flutter/material.dart';

import '../common/placeholder_module_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderModuleScreen(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
    );
  }
}
