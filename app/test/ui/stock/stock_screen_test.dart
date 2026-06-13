import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/constants/stock_config.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/stock_providers.dart';
import 'package:inventory_mobile/domain/models/stock_overview_item.dart';
import 'package:inventory_mobile/domain/repositories/stock_repository.dart';
import 'package:inventory_mobile/ui/stock/stock_screen.dart';

void main() {
  group('StockScreen', () {
    testWidgets('starts with Central Branch and renders backend fields', (
      tester,
    ) async {
      final repository = _FakeStockRepository({
        StockConfig.developmentBranchId: const AppSuccess([
          StockOverviewItem(
            id: 'stock-low',
            productId: 'product-coffee',
            productName: 'Coffee Beans',
            sku: 'COF-001',
            branchId: StockConfig.developmentBranchId,
            branchName: 'Central Branch',
            availableQuantity: 4,
            minStock: 5,
            isLowStock: true,
          ),
          StockOverviewItem(
            id: 'stock-empty',
            productId: 'product-tea',
            productName: 'Green Tea',
            branchId: StockConfig.developmentBranchId,
            branchName: 'Central Branch',
            availableQuantity: 0,
            minStock: 3,
            isLowStock: true,
          ),
        ]),
      });

      await _pumpStockScreen(tester, repository);

      expect(repository.requestedBranchIds, [StockConfig.developmentBranchId]);
      expect(find.text('Central Branch'), findsWidgets);
      expect(find.text('Coffee Beans'), findsOneWidget);
      expect(find.text('COF-001'), findsOneWidget);
      expect(find.text('Green Tea'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('STOCK BAJO'), findsOneWidget);
      expect(find.text('AGOTADO'), findsOneWidget);
    });

    testWidgets('keeps search and filters working after changing branch', (
      tester,
    ) async {
      final repository = _FakeStockRepository({
        StockConfig.developmentBranchId: const AppSuccess([
          StockOverviewItem(
            id: 'central',
            productId: 'product-coffee',
            productName: 'Coffee Beans',
            branchId: StockConfig.developmentBranchId,
            branchName: 'Central Branch',
            availableQuantity: 8,
            minStock: 3,
            isLowStock: false,
          ),
        ]),
        StockConfig.developmentBranches[1].id: AppSuccess([
          StockOverviewItem(
            id: 'warehouse',
            productId: 'product-flour',
            productName: 'Warehouse Flour',
            sku: 'FLR-002',
            branchId: StockConfig.developmentBranches[1].id,
            branchName: 'Warehouse Branch',
            availableQuantity: 2,
            minStock: 5,
            isLowStock: true,
          ),
          StockOverviewItem(
            id: 'warehouse-empty',
            productId: 'product-sugar',
            productName: 'Warehouse Sugar',
            branchId: StockConfig.developmentBranches[1].id,
            branchName: 'Warehouse Branch',
            availableQuantity: 0,
            minStock: 4,
            isLowStock: true,
          ),
        ]),
      });

      await _pumpStockScreen(tester, repository);

      await _selectWarehouseBranch(tester);

      expect(repository.requestedBranchIds, [
        StockConfig.developmentBranchId,
        StockConfig.developmentBranches[1].id,
      ]);
      expect(find.text('Coffee Beans'), findsNothing);
      expect(find.text('Warehouse Flour'), findsOneWidget);
      expect(find.text('Warehouse Sugar'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'flour');
      await tester.pump();

      expect(find.text('Warehouse Flour'), findsOneWidget);
      expect(find.text('Warehouse Sugar'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Stock bajo'));
      await tester.pump();

      expect(find.text('Warehouse Flour'), findsOneWidget);
      expect(find.text('Warehouse Sugar'), findsNothing);
    });

    testWidgets('shows loading while changing branch', (tester) async {
      final warehouseCompleter =
          Completer<AppResult<List<StockOverviewItem>>>();
      final repository = _FakeStockRepository({
        StockConfig.developmentBranchId: const AppSuccess([
          StockOverviewItem(
            id: 'central',
            productId: 'product-coffee',
            productName: 'Coffee Beans',
            branchId: StockConfig.developmentBranchId,
            branchName: 'Central Branch',
            availableQuantity: 8,
            minStock: 3,
            isLowStock: false,
          ),
        ]),
        StockConfig.developmentBranches[1].id: warehouseCompleter.future,
      });

      await _pumpStockScreen(tester, repository);
      await _selectWarehouseBranch(tester, settle: false);

      expect(find.text('Cargando existencias...'), findsOneWidget);
      expect(find.text('Warehouse Branch'), findsWidgets);

      warehouseCompleter.complete(const AppSuccess([]));
      await tester.pumpAndSettle();

      expect(find.text('No se encontraron existencias'), findsOneWidget);
    });

    testWidgets('shows the expected empty state for an empty branch response', (
      tester,
    ) async {
      final repository = _FakeStockRepository({
        StockConfig.developmentBranchId: const AppSuccess([]),
      });

      await _pumpStockScreen(tester, repository);

      expect(find.text('No se encontraron existencias'), findsOneWidget);
      expect(find.text(StockConfig.developmentBranchName), findsOneWidget);
    });

    testWidgets('ignores an older branch response that arrives late', (
      tester,
    ) async {
      final centralCompleter = Completer<AppResult<List<StockOverviewItem>>>();
      final warehouseCompleter =
          Completer<AppResult<List<StockOverviewItem>>>();
      final repository = _FakeStockRepository({
        StockConfig.developmentBranchId: centralCompleter.future,
        StockConfig.developmentBranches[1].id: warehouseCompleter.future,
      });

      await _pumpStockScreen(tester, repository, settle: false);
      await _selectWarehouseBranch(tester, settle: false);

      warehouseCompleter.complete(
        AppSuccess([
          StockOverviewItem(
            id: 'warehouse',
            productId: 'product-flour',
            productName: 'Warehouse Flour',
            branchId: StockConfig.developmentBranches[1].id,
            branchName: 'Warehouse Branch',
            availableQuantity: 9,
            minStock: 3,
            isLowStock: false,
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Warehouse Branch'), findsWidgets);
      expect(find.text('Warehouse Flour'), findsOneWidget);

      centralCompleter.complete(
        const AppSuccess([
          StockOverviewItem(
            id: 'central',
            productId: 'product-coffee',
            productName: 'Coffee Beans',
            branchId: StockConfig.developmentBranchId,
            branchName: 'Central Branch',
            availableQuantity: 8,
            minStock: 3,
            isLowStock: false,
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(repository.requestedBranchIds, [
        StockConfig.developmentBranchId,
        StockConfig.developmentBranches[1].id,
      ]);
      expect(find.text('Warehouse Branch'), findsWidgets);
      expect(find.text('Warehouse Flour'), findsOneWidget);
      expect(find.text('Coffee Beans'), findsNothing);
    });

    testWidgets('shows a friendly network error for selected branch failures', (
      tester,
    ) async {
      final repository = _FakeStockRepository({
        StockConfig.developmentBranchId: const AppSuccess([
          StockOverviewItem(
            id: 'central',
            productId: 'product-coffee',
            productName: 'Coffee Beans',
            branchId: StockConfig.developmentBranchId,
            branchName: 'Central Branch',
            availableQuantity: 8,
            minStock: 3,
            isLowStock: false,
          ),
        ]),
        StockConfig.developmentBranches[1].id:
            const AppFailure<List<StockOverviewItem>>(
              AppException(
                code: AppErrorCode.networkError,
                message: 'Cannot reach the backend.',
              ),
            ),
      });

      await _pumpStockScreen(tester, repository);
      await _selectWarehouseBranch(tester);

      expect(
        find.text('No se pudieron cargar las existencias'),
        findsOneWidget,
      );
      expect(
        find.text('No fue posible conectar con el servidor.'),
        findsOneWidget,
      );
      expect(find.textContaining('network_error'), findsNothing);
      expect(find.textContaining('Cannot reach the backend'), findsNothing);
      expect(find.text('Warehouse Branch'), findsWidgets);
      expect(find.widgetWithText(FilledButton, 'Reintentar'), findsOneWidget);
    });

    for (final scenario in <_ErrorScenario>[
      _ErrorScenario(
        name: '401',
        exception: AppException(
          code: AppErrorCode.unauthorized,
          message: 'Backend returned unexpected status 401.',
          details: {'statusCode': 401},
        ),
        expectedMessage: 'Tu sesión expiró. Inicia sesión nuevamente.',
      ),
      _ErrorScenario(
        name: '403',
        exception: AppException(
          code: AppErrorCode.forbidden,
          message: 'Backend returned unexpected status 403.',
          details: {'statusCode': 403},
        ),
        expectedMessage: 'No tienes permisos para consultar el stock.',
      ),
      _ErrorScenario(
        name: '404',
        exception: AppException(
          code: AppErrorCode.notFound,
          message: 'Backend returned unexpected status 404.',
          details: {'statusCode': 404},
        ),
        expectedMessage:
            'No se encontró información de stock para esta sucursal.',
      ),
      _ErrorScenario(
        name: '500',
        exception: AppException(
          code: AppErrorCode.unexpected,
          message: 'Backend returned unexpected status 500.',
          details: {'statusCode': 500},
        ),
        expectedMessage: 'Ocurrió un error interno. Inténtalo más tarde.',
      ),
      _ErrorScenario(
        name: '503',
        exception: AppException(
          code: AppErrorCode.serviceUnavailable,
          message: 'Backend returned unexpected status 503.',
          details: {'statusCode': 503},
        ),
        expectedMessage: 'El servicio no está disponible. Inténtalo más tarde.',
      ),
    ]) {
      testWidgets('shows friendly message for ${scenario.name}', (
        tester,
      ) async {
        final repository = _FakeStockRepository({
          StockConfig.developmentBranchId: AppFailure<List<StockOverviewItem>>(
            scenario.exception,
          ),
        });

        await _pumpStockScreen(tester, repository);

        expect(find.text(scenario.expectedMessage), findsOneWidget);
        expect(
          find.textContaining(scenario.exception.code.value),
          findsNothing,
        );
        expect(find.textContaining(scenario.exception.message), findsNothing);
        expect(find.textContaining('AppException'), findsNothing);
      });
    }
  });
}

Future<void> _pumpStockScreen(
  WidgetTester tester,
  _FakeStockRepository repository, {
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [stockRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: const Material(child: StockScreen()),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _selectWarehouseBranch(
  WidgetTester tester, {
  bool settle = true,
}) async {
  await tester.tap(find.byType(DropdownButton<String>));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(seconds: 1));
  }
  await tester.tap(find.text('Warehouse Branch').last);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

final class _ErrorScenario {
  const _ErrorScenario({
    required this.name,
    required this.exception,
    required this.expectedMessage,
  });

  final String name;
  final AppException exception;
  final String expectedMessage;
}

final class _FakeStockRepository implements StockRepository {
  _FakeStockRepository(this.resultsByBranch);

  final Map<String, FutureOr<AppResult<List<StockOverviewItem>>>>
  resultsByBranch;
  final List<String> requestedBranchIds = [];

  @override
  Future<AppResult<List<StockOverviewItem>>> getStockByBranch(
    String branchId,
  ) async {
    requestedBranchIds.add(branchId);
    final result = resultsByBranch[branchId];
    if (result == null) {
      return const AppSuccess([]);
    }
    return Future.value(result);
  }
}
