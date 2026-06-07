import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_product_data_source.dart';
import 'package:inventory_mobile/data/dto/paginated_product_rest_dto.dart';
import 'package:inventory_mobile/data/dto/product_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/product_repository_impl.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';
import 'package:inventory_mobile/domain/models/product.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductDataSource extends Mock implements RestApiProductDataSource {}

ProductRestDto _productDto({bool isActive = true}) {
  return ProductRestDto(
    id: 'product-id',
    name: 'Rice 1kg',
    sku: 'RICE-001',
    category: 'Food',
    minStock: 10,
    isActive: isActive,
    createdAt: DateTime.utc(2026, 6, 5, 20),
  );
}

void main() {
  late _MockProductDataSource dataSource;
  late ProductRepositoryImpl sut;

  setUp(() {
    dataSource = _MockProductDataSource();
    sut = ProductRepositoryImpl(dataSource);
  });

  group('getProducts', () {
    test('returns AppSuccess with mapped paginated products', () async {
      when(
        () => dataSource.getProducts(isActive: true, page: 1, pageSize: 100),
      ).thenAnswer(
        (_) async => PaginatedProductRestDto(
          items: [_productDto()],
          total: 1,
          page: 1,
          pageSize: 100,
          hasNextPage: false,
        ),
      );

      final result = await sut.getProducts(isActive: true);

      expect(result, isA<AppSuccess<PaginatedResult<Product>>>());
      expect(result.dataOrNull?.items.single.name, 'Rice 1kg');
    });

    test('preserves AppException failures from the data source', () async {
      const exception = AppException(
        code: AppErrorCode.unauthorized,
        message: 'Unauthorized.',
      );
      when(
        () => dataSource.getProducts(isActive: true, page: 1, pageSize: 100),
      ).thenThrow(exception);

      final result = await sut.getProducts(isActive: true);

      expect(result, isA<AppFailure<PaginatedResult<Product>>>());
      expect(result.exceptionOrNull, same(exception));
    });
  });

  group('activateProduct', () {
    test('returns AppSuccess when activate succeeds', () async {
      when(
        () => dataSource.activateProduct('product-id'),
      ).thenAnswer((_) async {});

      final result = await sut.activateProduct('product-id');

      expect(result, isA<AppSuccess<void>>());
      verify(() => dataSource.activateProduct('product-id')).called(1);
    });
  });

  group('deactivateProduct', () {
    test('returns AppFailure unexpected for non-AppException errors', () async {
      when(
        () => dataSource.deactivateProduct('product-id'),
      ).thenThrow(StateError('boom'));

      final result = await sut.deactivateProduct('product-id');

      expect(result, isA<AppFailure<void>>());
      expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
    });
  });
}
