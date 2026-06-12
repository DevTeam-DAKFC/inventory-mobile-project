import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/providers/health_providers.dart';
import '../../domain/models/backend_health.dart';

class BackendHealthScreen extends ConsumerWidget {
  const BackendHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(backendHealthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backend health')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: asyncResult.when(
            loading: () => const _LoadingView(),
            error: (error, stackTrace) => _FailureView(
              title: 'Health check failed unexpectedly.',
              message: error.toString(),
              onRetry: () => ref.invalidate(backendHealthProvider),
            ),
            data: (result) => result.when(
              success: (health) => _SuccessView(health: health),
              failure: (exception) => _FailureView(
                title: 'Could not reach backend.',
                message: _formatException(exception),
                onRetry: () => ref.invalidate(backendHealthProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatException(AppException exception) =>
      '${exception.code.value}: ${exception.message}';
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Checking backend...'),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.health});

  final BackendHealth health;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = health.isOk
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          health.isOk ? Icons.check_circle_outline : Icons.warning_amber,
          size: 72,
          color: color,
        ),
        const SizedBox(height: 16),
        Text('Status: ${health.status}', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Service: ${health.service}', style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 72, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
