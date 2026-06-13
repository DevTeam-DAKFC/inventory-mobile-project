import 'package:flutter/material.dart';

class SessionRestoreScreen extends StatelessWidget {
  const SessionRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(height: 16),
              Text('Restoring session...', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
