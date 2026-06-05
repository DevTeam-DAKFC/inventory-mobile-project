import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/health_providers.dart';
import 'package:inventory_mobile/domain/models/backend_health.dart';
import 'package:inventory_mobile/ui/foundation/backend_health_screen.dart';

void main() {
  group('BackendHealthScreen', () {
    testWidgets('shows a loading indicator while the check is in flight',
        (tester) async {
      final completer = Completer<AppResult<BackendHealth>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backendHealthProvider.overrideWith((_) => completer.future),
          ],
          child: const MaterialApp(home: BackendHealthScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Checking backend...'), findsOneWidget);

      completer.complete(
        const AppSuccess(
          BackendHealth(status: 'ok', service: 'Inventory.Api'),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('shows status and service when the result is AppSuccess',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backendHealthProvider.overrideWith(
              (_) async => const AppSuccess(
                BackendHealth(status: 'ok', service: 'Inventory.Api'),
              ),
            ),
          ],
          child: const MaterialApp(home: BackendHealthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Status: ok'), findsOneWidget);
      expect(find.text('Service: Inventory.Api'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets(
        'shows error message and retry button when the result is AppFailure',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backendHealthProvider.overrideWith(
              (_) async => const AppFailure<BackendHealth>(
                AppException(
                  code: AppErrorCode.networkError,
                  message: 'Cannot reach the backend.',
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: BackendHealthScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not reach backend.'), findsOneWidget);
      expect(
        find.text('network_error: Cannot reach the backend.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    });
  });
}
