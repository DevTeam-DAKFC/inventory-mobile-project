import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/branch_providers.dart';
import 'package:inventory_mobile/domain/models/branch.dart';
import 'package:inventory_mobile/domain/repositories/branch_repository.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/ui/branches/branches_screen.dart';

Widget _buildSubject({
  required Future<AppResult<List<Branch>>> Function() loader,
  AppSession? session,
  BranchRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      branchesProvider.overrideWith((_) => loader()),
      if (repository != null)
        branchRepositoryProvider.overrideWithValue(repository),
      if (session != null) appSessionProvider.overrideWithValue(session),
    ],
    child: const MaterialApp(home: BranchesScreen()),
  );
}

final class _FakeBranchRepository implements BranchRepository {
  int createCalls = 0;
  int updateCalls = 0;
  int deactivateCalls = 0;
  int reactivateCalls = 0;
  String? lastName;
  String? lastAddress;
  AppException? createFailure;
  AppException? updateFailure;

  @override
  Future<AppResult<List<Branch>>> getBranches({bool? isActive}) async =>
      const AppSuccess([]);

  @override
  Future<AppResult<Branch>> createBranch({
    required String name,
    String? address,
  }) async {
    createCalls += 1;
    lastName = name;
    lastAddress = address;
    if (createFailure case final failure?) {
      return AppFailure(failure);
    }
    return AppSuccess(
      Branch(
        id: 'created',
        name: name.trim(),
        address: address,
        isActive: true,
      ),
    );
  }

  @override
  Future<AppResult<Branch>> updateBranch({
    required String branchId,
    required String name,
    String? address,
  }) async {
    updateCalls += 1;
    lastName = name;
    lastAddress = address;
    if (updateFailure case final failure?) {
      return AppFailure(failure);
    }
    return AppSuccess(
      Branch(id: branchId, name: name.trim(), address: address, isActive: true),
    );
  }

  @override
  Future<AppResult<void>> deactivateBranch(String branchId) async {
    deactivateCalls += 1;
    return const AppSuccess(null);
  }

  @override
  Future<AppResult<void>> reactivateBranch(String branchId) async {
    reactivateCalls += 1;
    return const AppSuccess(null);
  }
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
      expect(
        find.text('No fue posible conectar con el servidor.'),
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

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.text('Todas'), findsNothing);
      expect(find.text('Activas'), findsNothing);
      expect(find.text('Inactivas'), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.block), findsNothing);
    });

    testWidgets('shows admin actions for admin', (tester) async {
      final session = AppSession()..signInAsDemoAdmin();

      await tester.pumpWidget(
        _buildSubject(
          loader: () async => const AppSuccess(_branches),
          session: session,
          repository: _FakeBranchRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('Activas'), findsOneWidget);
      expect(find.text('Inactivas'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
      expect(find.byIcon(Icons.block), findsNWidgets(2));
    });

    testWidgets('admin can create a branch from the form', (tester) async {
      final session = AppSession()..signInAsDemoAdmin();
      final repository = _FakeBranchRepository();
      var loadCalls = 0;

      await tester.pumpWidget(
        _buildSubject(
          loader: () async {
            loadCalls += 1;
            return const AppSuccess(_branches);
          },
          session: session,
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Nueva sucursal'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar sucursal'));
      await tester.pump();

      expect(
        find.text('El nombre de la sucursal es requerido.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre de la sucursal'),
        ' Sucursal Oeste ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dirección'),
        ' Escazu ',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar sucursal'));
      await tester.pumpAndSettle();

      expect(repository.createCalls, 1);
      expect(repository.lastName, ' Sucursal Oeste ');
      expect(repository.lastAddress, ' Escazu ');
      expect(loadCalls, greaterThanOrEqualTo(2));
    });

    testWidgets('create failure keeps the form open with a friendly message', (
      tester,
    ) async {
      final session = AppSession()..signInAsDemoAdmin();
      final repository = _FakeBranchRepository()
        ..createFailure = const AppException(
          code: AppErrorCode.forbidden,
          message: 'technical forbidden',
        );

      await tester.pumpWidget(
        _buildSubject(
          loader: () async => const AppSuccess(_branches),
          session: session,
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre de la sucursal'),
        'Sucursal Oeste',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar sucursal'));
      await tester.pumpAndSettle();

      expect(find.text('Nueva sucursal'), findsOneWidget);
      expect(
        find.text('No tienes permisos para realizar esta acción.'),
        findsOneWidget,
      );
    });

    testWidgets('admin can edit a branch and refresh the active list', (
      tester,
    ) async {
      final session = AppSession()..signInAsDemoAdmin();
      final repository = _FakeBranchRepository();
      var loadCalls = 0;

      await tester.pumpWidget(
        _buildSubject(
          loader: () async {
            loadCalls += 1;
            return const AppSuccess(_branches);
          },
          session: session,
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();
      expect(find.text('Editar sucursal'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre de la sucursal'),
        'Sucursal Central Actualizada',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar sucursal'));
      await tester.pumpAndSettle();

      expect(repository.updateCalls, 1);
      expect(repository.lastName, 'Sucursal Central Actualizada');
      expect(loadCalls, greaterThanOrEqualTo(2));
    });

    testWidgets('edit failure keeps the form open', (tester) async {
      final session = AppSession()..signInAsDemoAdmin();
      final repository = _FakeBranchRepository()
        ..updateFailure = const AppException(
          code: AppErrorCode.conflict,
          message: 'Ya existe una sucursal con ese nombre.',
        );

      await tester.pumpWidget(
        _buildSubject(
          loader: () async => const AppSuccess(_branches),
          session: session,
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar sucursal'));
      await tester.pumpAndSettle();

      expect(find.text('Editar sucursal'), findsOneWidget);
      expect(
        find.text('Ya existe una sucursal con ese nombre.'),
        findsOneWidget,
      );
    });

    testWidgets('admin confirms before deactivating a branch', (tester) async {
      final session = AppSession()..signInAsDemoAdmin();
      final repository = _FakeBranchRepository();
      var loadCalls = 0;

      await tester.pumpWidget(
        _buildSubject(
          loader: () async {
            loadCalls += 1;
            return const AppSuccess(_branches);
          },
          session: session,
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.block).first);
      await tester.pumpAndSettle();

      expect(find.text('Desactivar sucursal'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
      await tester.pumpAndSettle();

      expect(repository.deactivateCalls, 1);
      expect(loadCalls, greaterThanOrEqualTo(2));
    });

    testWidgets('admin can reactivate an inactive branch', (tester) async {
      final session = AppSession()..signInAsDemoAdmin();
      final repository = _FakeBranchRepository();
      var activeLoadCalls = 0;
      var inactiveLoadCalls = 0;
      const inactiveBranches = [
        Branch(
          id: '3',
          name: 'Sucursal Cerrada',
          address: 'Cartago',
          isActive: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            branchesProvider.overrideWith((_) async {
              activeLoadCalls += 1;
              return const AppSuccess(_branches);
            }),
            inactiveBranchesProvider.overrideWith((_) async {
              inactiveLoadCalls += 1;
              return const AppSuccess(inactiveBranches);
            }),
            branchRepositoryProvider.overrideWithValue(repository),
            appSessionProvider.overrideWithValue(session),
          ],
          child: const MaterialApp(home: BranchesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inactivas'));
      await tester.pumpAndSettle();

      expect(find.text('Sucursal Cerrada'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reactivar'));
      await tester.pumpAndSettle();

      expect(repository.reactivateCalls, 1);
      expect(find.text('Sucursal Cerrada'), findsNothing);
      expect(activeLoadCalls, greaterThanOrEqualTo(2));
      expect(inactiveLoadCalls, greaterThanOrEqualTo(2));
    });
  });
}
