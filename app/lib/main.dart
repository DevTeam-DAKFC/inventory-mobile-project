import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/foundation/backend_health_screen.dart';

void main() {
  runApp(const ProviderScope(child: InventoryMobileApp()));
}

class InventoryMobileApp extends StatelessWidget {
  const InventoryMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BackendHealthScreen(),
    );
  }
}
