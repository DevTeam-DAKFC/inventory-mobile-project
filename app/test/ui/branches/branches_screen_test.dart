import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/branch_providers.dart';
import 'package:inventory_mobile/domain/models/branch.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/ui/branches/branches_screen.dart';

Widget _buildSubject({
  required Future<AppResult<List<Branch>>> Function() loader,
  AppSession? session,
}) {
  return ProviderScope(
    overrides: [
      branchesProvider.overrideWith((_) => loader()),
      if (session != null) appSessionProvider.overrideWithValue(session),
    ],
    child: const MaterialApp(home: BranchesScreen()),
  );
}

const _branches = [
  Branch(
    id: '1',
    name: 'Sucursal Central',
    address: 'San Jose centro',
    isActive: true,
  ),
  Branch(id: '2', name: 'Sucursal Norte', address: 'Heredia', isActive: true),
];

void main() {
  group('BranchesScreen', () {
    testWidgets('shows loading state while branches are in flight', (
      tester,
    ) async {
      final completer = Completer<AppResult<List<Branch>>>();

      await tester.pumpWidget(_buildSubject(loader: () => completer.future));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando sucursales...'), findsOneWidget);

      completer.complete(const AppSuccess(_branches));
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when there are no branches', (tester) async {
      await tester.pumpWidget(
        _buildSubject(loader: () async => const AppSuccess([])),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No hay sucursales activas disponibles.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error state when repository returns failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          loader: () async => const AppFailure<List<Branch>>(
            AppException(
              code: AppErrorCode.networkError,
              message: 'Could not load branches.',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No se pudieron cargar las sucursales.'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'Intentar de nuevo'),
        findsOneWidget,
      );
    });

    testWidgets('renders branch list and selection state', (tester) async {
      await tester.pumpWidget(
        _buildSubject(loader: () async => const AppSuccess(_branches)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sucursal Central'), findsOneWidget);
      expect(find.text('Sucursal Norte'), findsOneWidget);

      await tester.tap(find.text('Sucursal Norte'));
      await tester.pumpAndSettle();

      expect(find.text('Seleccionada'), findsOneWidget);
    });

    testWidgets('does not show admin action for collaborator', (tester) async {
      final session = AppSession()..signInAsDemoCollaborator();

      await tester.pumpWidget(
        _buildSubject(
          loader: () async => const AppSuccess(_branches),
          session: session,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
    });
  });
}
