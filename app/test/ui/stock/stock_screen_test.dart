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
    testWidgets('loads development branch stock and renders backend fields', (
      tester,
    ) async {
      final repository = _FakeStockRepository(
        const AppSuccess([
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
      );

      await _pumpStockScreen(tester, repository);

      expect(repository.requestedBranchId, StockConfig.developmentBranchId);
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

    testWidgets('shows the expected empty state for an empty stock response', (
      tester,
    ) async {
      await _pumpStockScreen(
        tester,
        _FakeStockRepository(const AppSuccess([])),
      );

      expect(find.text('No se encontraron existencias'), findsOneWidget);
      expect(find.text(StockConfig.developmentBranchName), findsOneWidget);
    });

    testWidgets('shows the expected error state for backend failures', (
      tester,
    ) async {
      await _pumpStockScreen(
        tester,
        _FakeStockRepository(
          const AppFailure<List<StockOverviewItem>>(
            AppException(
              code: AppErrorCode.networkError,
              message: 'Cannot reach the backend.',
            ),
          ),
        ),
      );

      expect(
        find.text('No se pudieron cargar las existencias'),
        findsOneWidget,
      );
      expect(
        find.text('network_error: Cannot reach the backend.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Reintentar'), findsOneWidget);
    });
  });
}

Future<void> _pumpStockScreen(
  WidgetTester tester,
  _FakeStockRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [stockRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: Material(child: StockScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

final class _FakeStockRepository implements StockRepository {
  _FakeStockRepository(this.result);

  final AppResult<List<StockOverviewItem>> result;
  String? requestedBranchId;

  @override
  Future<AppResult<List<StockOverviewItem>>> getStockByBranch(
    String branchId,
  ) async {
    requestedBranchId = branchId;
    return result;
  }
}
