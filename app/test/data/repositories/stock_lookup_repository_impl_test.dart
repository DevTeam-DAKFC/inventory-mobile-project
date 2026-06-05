import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_stock_lookup_data_source.dart';
import 'package:inventory_mobile/data/dto/stock_lookup_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/stock_lookup_repository_impl.dart';
import 'package:inventory_mobile/domain/models/stock_lookup.dart';
import 'package:mocktail/mocktail.dart';

class _MockStockLookupDataSource extends Mock
    implements RestApiStockLookupDataSource {}

StockLookupRestDto _stockLookupDto() {
  return StockLookupRestDto(
    id: 'stock-id',
    availableQuantity: 12,
    minStock: 10,
    isLowStock: false,
    product: const StockLookupProductRestDto(
      id: 'product-id',
      name: 'Rice 1kg',
      sku: 'RICE-001',
      category: 'Food',
    ),
    branch: const StockLookupBranchRestDto(
      id: 'branch-id',
      name: 'Central Branch',
    ),
  );
}

void main() {
  late _MockStockLookupDataSource dataSource;
  late StockLookupRepositoryImpl sut;

  setUp(() {
    dataSource = _MockStockLookupDataSource();
    sut = StockLookupRepositoryImpl(dataSource);
  });

  group('getStockLookup', () {
    test('returns AppSuccess with mapped stock lookup', () async {
      when(
        () => dataSource.getStockLookup(
          productId: 'product-id',
          branchId: 'branch-id',
        ),
      ).thenAnswer((_) async => _stockLookupDto());

      final result = await sut.getStockLookup(
        productId: 'product-id',
        branchId: 'branch-id',
      );

      expect(result, isA<AppSuccess<StockLookup>>());
      expect(result.dataOrNull?.availableQuantity, 12);
      expect(result.dataOrNull?.product.name, 'Rice 1kg');
      expect(result.dataOrNull?.branch.name, 'Central Branch');
    });

    test('preserves AppException failures from the data source', () async {
      const exception = AppException(
        code: AppErrorCode.notFound,
        message: 'Stock not found.',
      );
      when(
        () => dataSource.getStockLookup(
          productId: 'product-id',
          branchId: 'branch-id',
        ),
      ).thenThrow(exception);

      final result = await sut.getStockLookup(
        productId: 'product-id',
        branchId: 'branch-id',
      );

      expect(result, isA<AppFailure<StockLookup>>());
      expect(result.exceptionOrNull, same(exception));
    });

    test('returns AppFailure unexpected for non-AppException errors', () async {
      when(
        () => dataSource.getStockLookup(
          productId: 'product-id',
          branchId: 'branch-id',
        ),
      ).thenThrow(StateError('boom'));

      final result = await sut.getStockLookup(
        productId: 'product-id',
        branchId: 'branch-id',
      );

      expect(result, isA<AppFailure<StockLookup>>());
      expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
      expect(result.exceptionOrNull?.cause, isA<StateError>());
    });
  });
}
