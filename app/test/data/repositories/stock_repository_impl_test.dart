import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_stock_data_source.dart';
import 'package:inventory_mobile/data/dto/stock_overview_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/stock_repository_impl.dart';
import 'package:inventory_mobile/domain/models/stock_overview_item.dart';
import 'package:mocktail/mocktail.dart';

class _MockStockDataSource extends Mock implements RestApiStockDataSource {}

const _developmentBranchId = '10000000-0000-0000-0000-000000000001';

void main() {
  late _MockStockDataSource dataSource;
  late StockRepositoryImpl sut;

  setUp(() {
    dataSource = _MockStockDataSource();
    sut = StockRepositoryImpl(dataSource);
  });

  group('StockRepositoryImpl.getStockByBranch', () {
    test('returns AppSuccess with mapped StockOverviewItem values', () async {
      when(
        () => dataSource.fetchStockByBranch(_developmentBranchId),
      ).thenAnswer(
        (_) async => [
          StockOverviewRestDto(
            id: 'stock-guid',
            productId: 'product-guid',
            productName: 'Coffee Beans',
            sku: 'COF-001',
            branchId: _developmentBranchId,
            branchName: 'Central Branch',
            availableQuantity: 4,
            minStock: 5,
            isLowStock: true,
            updatedAt: DateTime.utc(2026, 6, 4),
          ),
        ],
      );

      final result = await sut.getStockByBranch(_developmentBranchId);

      expect(result, isA<AppSuccess<List<StockOverviewItem>>>());
      expect(result.dataOrNull?.single.productName, 'Coffee Beans');
      expect(result.dataOrNull?.single.branchName, 'Central Branch');
      expect(result.dataOrNull?.single.isLowStock, isTrue);
    });

    test(
      'returns AppFailure preserving AppException from the data source',
      () async {
        const exception = AppException(
          code: AppErrorCode.networkError,
          message: 'Cannot reach the backend.',
        );
        when(
          () => dataSource.fetchStockByBranch(_developmentBranchId),
        ).thenThrow(exception);

        final result = await sut.getStockByBranch(_developmentBranchId);

        expect(result, isA<AppFailure<List<StockOverviewItem>>>());
        expect(result.exceptionOrNull, same(exception));
      },
    );
  });
}
