import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_product_data_source.dart';
import 'package:inventory_mobile/data/dto/paginated_products_rest_dto.dart';
import 'package:inventory_mobile/data/dto/product_requests.dart';
import 'package:inventory_mobile/data/dto/product_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/product_repository_impl.dart';
import 'package:inventory_mobile/domain/models/product_list_query.dart';
import 'package:inventory_mobile/domain/models/product_image_input.dart';
import 'package:inventory_mobile/domain/models/product_mutations.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductDataSource extends Mock implements RestApiProductDataSource {}

void main() {
  late _MockProductDataSource dataSource;
  late ProductRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(
      const ProductCreateRequest(
        name: 'fallback',
        sku: 'fallback',
        category: 'fallback',
        minStock: 0,
      ),
    );
    registerFallbackValue(const ProductUpdateRequest(UpdateProductInput()));
    registerFallbackValue(
      ProductImageInput(
        fileName: 'fallback.jpg',
        bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF]),
        mimeType: 'image/jpeg',
      ),
    );
  });

  setUp(() {
    dataSource = _MockProductDataSource();
    sut = ProductRepositoryImpl(dataSource);
  });

  test('returns successful paginated domain response', () async {
    const query = ProductListQuery(page: 1);
    when(
      () => dataSource.listProducts(query),
    ).thenAnswer((_) async => _pageDto());

    final result = await sut.listProducts(query);

    expect(result, isA<AppSuccess>());
    expect(result.dataOrNull?.items.single.id, 'product_1');
  });

  test('creates product and preserves imageUrl', () async {
    when(
      () => dataSource.createProduct(any()),
    ).thenAnswer((_) async => _productDto());

    final result = await sut.createProduct(
      const CreateProductInput(
        name: 'Arroz',
        sku: 'ARR-001',
        category: 'Abarrotes',
        minStock: 10,
        imageUrl: 'https://example.com/product.jpg',
      ),
    );

    expect(result.dataOrNull?.imageUrl, 'https://example.com/product.jpg');
  });

  test('updates product through partial request', () async {
    when(
      () => dataSource.updateProduct('product_1', any()),
    ).thenAnswer((_) async => _productDto());

    final result = await sut.updateProduct(
      'product_1',
      const UpdateProductInput(name: PatchField.value('Arroz')),
    );

    expect(result, isA<AppSuccess>());
  });

  test('deactivates product successfully', () async {
    when(
      () => dataSource.deactivateProduct('product_1'),
    ).thenAnswer((_) async {});

    final result = await sut.deactivateProduct('product_1');

    expect(result, isA<AppSuccess<void>>());
  });

  test('activates product successfully', () async {
    when(() => dataSource.activateProduct('product_1')).thenAnswer((_) async {});

    final result = await sut.activateProduct('product_1');

    expect(result, isA<AppSuccess<void>>());
  });

  test('uploads validated product image successfully', () async {
    when(
      () => dataSource.uploadProductImage('product_1', any()),
    ).thenAnswer((_) async => _productDto());

    final result = await sut.uploadProductImage(
      'product_1',
      ProductImageInput(
        fileName: 'product.jpg',
        bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]),
        mimeType: 'image/jpeg',
      ),
    );

    expect(result, isA<AppSuccess>());
    expect(result.dataOrNull?.imageUrl, 'https://example.com/product.jpg');
  });

  test('rejects invalid image before calling data source', () async {
    final result = await sut.uploadProductImage(
      'product_1',
      ProductImageInput(
        fileName: 'invalid.jpg',
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      ),
    );

    expect(result.exceptionOrNull?.code, AppErrorCode.validationError);
    verifyNever(() => dataSource.uploadProductImage(any(), any()));
  });

  for (final code in <AppErrorCode>[
    AppErrorCode.validationError,
    AppErrorCode.notFound,
    AppErrorCode.networkError,
    AppErrorCode.timeout,
  ]) {
    test('preserves ${code.value} from image upload', () async {
      final exception = AppException(code: code, message: 'upload failed');
      when(
        () => dataSource.uploadProductImage('product_1', any()),
      ).thenThrow(exception);

      final result = await sut.uploadProductImage(
        'product_1',
        ProductImageInput(
          fileName: 'product.jpg',
          bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]),
          mimeType: 'image/jpeg',
        ),
      );

      expect(result.exceptionOrNull, same(exception));
    });
  }

  for (final code in <AppErrorCode>[
    AppErrorCode.validationError,
    AppErrorCode.conflict,
    AppErrorCode.notFound,
    AppErrorCode.networkError,
    AppErrorCode.timeout,
    AppErrorCode.unexpected,
  ]) {
    test('preserves ${code.value} from data source', () async {
      final exception = AppException(
        code: code,
        message: 'failure',
        details: code == AppErrorCode.conflict
            ? <String, Object?>{
                'fieldErrors': [
                  <String, dynamic>{'field': 'sku', 'message': 'duplicate'},
                  <String, dynamic>{'field': 'barcode', 'message': 'duplicate'},
                ],
              }
            : null,
      );
      when(() => dataSource.getProduct('product_1')).thenThrow(exception);

      final result = await sut.getProduct('product_1');

      expect(result.exceptionOrNull, same(exception));
      if (code == AppErrorCode.conflict) {
        expect(result.exceptionOrNull?.details.toString(), contains('sku'));
        expect(result.exceptionOrNull?.details.toString(), contains('barcode'));
      }
    });
  }
}

PaginatedProductsRestDto _pageDto() => PaginatedProductsRestDto(
  items: [_productDto()],
  total: 1,
  page: 1,
  pageSize: 20,
  hasNextPage: false,
);

ProductRestDto _productDto() => ProductRestDto(
  id: 'product_1',
  name: 'Arroz',
  sku: 'ARR-001',
  category: 'Abarrotes',
  minStock: 10,
  isActive: true,
  createdAt: DateTime.utc(2026, 6, 2),
  imageUrl: 'https://example.com/product.jpg',
);
