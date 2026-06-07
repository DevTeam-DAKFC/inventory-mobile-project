import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_product_data_source.dart';
import 'package:inventory_mobile/data/dto/product_requests.dart';
import 'package:inventory_mobile/domain/models/product_list_query.dart';
import 'package:inventory_mobile/domain/models/product_image_input.dart';
import 'package:inventory_mobile/domain/models/product_mutations.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late RestApiProductDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiProductDataSource(dio);
  });

  test('GET /products without filters sends empty query parameters', () async {
    when(
      () => dio.get<dynamic>('/products', queryParameters: <String, dynamic>{}),
    ).thenAnswer((_) async => _response(_pageJson()));

    final result = await sut.listProducts(const ProductListQuery());

    expect(result.items, hasLength(1));
  });

  test('GET /products sends all filters and omits empty strings', () async {
    when(
      () => dio.get<dynamic>(
        '/products',
        queryParameters: <String, dynamic>{
          'q': 'rice',
          'category': 'Abarrotes',
          'isActive': false,
          'lowStockOnly': true,
          'page': 2,
          'pageSize': 10,
        },
      ),
    ).thenAnswer((_) async => _response(_pageJson()));

    await sut.listProducts(
      const ProductListQuery(
        q: ' rice ',
        category: 'Abarrotes',
        isActive: false,
        lowStockOnly: true,
        page: 2,
        pageSize: 10,
      ),
    );

    verify(
      () => dio.get<dynamic>(
        '/products',
        queryParameters: <String, dynamic>{
          'q': 'rice',
          'category': 'Abarrotes',
          'isActive': false,
          'lowStockOnly': true,
          'page': 2,
          'pageSize': 10,
        },
      ),
    ).called(1);
  });

  test('GET /products omits whitespace-only filters', () async {
    when(
      () => dio.get<dynamic>('/products', queryParameters: <String, dynamic>{}),
    ).thenAnswer((_) async => _response(_pageJson()));

    await sut.listProducts(const ProductListQuery(q: ' ', category: '  '));

    verify(
      () => dio.get<dynamic>('/products', queryParameters: <String, dynamic>{}),
    ).called(1);
  });

  test('GET /products/{productId} parses Product', () async {
    when(
      () => dio.get<dynamic>('/products/product_1'),
    ).thenAnswer((_) async => _response(_productJson()));

    final product = await sut.getProduct('product_1');

    expect(product.id, 'product_1');
  });

  test(
    'GET /products/{productId} rejects a map with non-string keys',
    () async {
      when(
        () => dio.get<dynamic>('/products/product_1'),
      ).thenAnswer((_) async => _response(<Object, Object>{1: 'invalid'}));

      await expectLater(
        sut.getProduct('product_1'),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    },
  );

  test('POST /products serializes request', () async {
    const request = ProductCreateRequest(
      name: 'Arroz',
      sku: 'ARR-001',
      category: 'Abarrotes',
      minStock: 10,
    );
    when(
      () => dio.post<dynamic>('/products', data: request.toJson()),
    ).thenAnswer((_) async => _response(_productJson(), statusCode: 201));

    await sut.createProduct(request);

    verify(
      () => dio.post<dynamic>('/products', data: request.toJson()),
    ).called(1);
  });

  test('PATCH /products/{productId} serializes only update fields', () async {
    const request = ProductUpdateRequest(
      UpdateProductInput(name: PatchField.value('Nuevo nombre')),
    );
    when(
      () => dio.patch<dynamic>('/products/product_1', data: request.toJson()),
    ).thenAnswer((_) async => _response(_productJson()));

    await sut.updateProduct('product_1', request);

    verify(
      () => dio.patch<dynamic>('/products/product_1', data: request.toJson()),
    ).called(1);
  });

  test(
    'PATCH /products/{productId}/deactivate accepts 204 without body',
    () async {
      when(
        () => dio.patch<dynamic>('/products/product_1/deactivate'),
      ).thenAnswer((_) async => _response(null, statusCode: 204));

      await sut.deactivateProduct('product_1');

      verify(
        () => dio.patch<dynamic>('/products/product_1/deactivate'),
      ).called(1);
    },
  );

  test('PATCH /products/{productId}/activate accepts 204 without body', () async {
    when(
      () => dio.patch<dynamic>('/products/product_1/activate'),
    ).thenAnswer((_) async => _response(null, statusCode: 204));

    await sut.activateProduct('product_1');

    verify(() => dio.patch<dynamic>('/products/product_1/activate')).called(1);
  });

  test(
    'POST /products/{productId}/image sends multipart file metadata',
    () async {
      late FormData capturedFormData;
      when(
        () => dio.post<dynamic>(
          '/products/product_1/image',
          data: any(named: 'data'),
        ),
      ).thenAnswer((invocation) async {
        capturedFormData = invocation.namedArguments[#data] as FormData;
        return _response(
          _productJson()..['imageUrl'] = '/uploads/products/product_1.jpg',
        );
      });

      final product = await sut.uploadProductImage(
        'product_1',
        ProductImageInput(
          fileName: 'product.jpg',
          bytes: _jpegBytes(),
          mimeType: 'image/jpeg',
        ),
      );

      final fileEntry = capturedFormData.files.single;
      expect(fileEntry.key, 'file');
      expect(fileEntry.value.filename, 'product.jpg');
      expect(fileEntry.value.contentType.toString(), 'image/jpeg');
      expect(capturedFormData.fields, isEmpty);
      expect(product.imageUrl, '/uploads/products/product_1.jpg');
    },
  );
}

Response<dynamic> _response(dynamic data, {int statusCode = 200}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/products'),
    statusCode: statusCode,
    data: data,
  );
}

Map<String, dynamic> _pageJson() => <String, dynamic>{
  'items': [_productJson()],
  'total': 1,
  'page': 1,
  'pageSize': 20,
  'hasNextPage': false,
};

Map<String, dynamic> _productJson() => <String, dynamic>{
  'id': 'product_1',
  'name': 'Arroz',
  'sku': 'ARR-001',
  'barcode': null,
  'category': 'Abarrotes',
  'description': null,
  'imageUrl': null,
  'minStock': 10,
  'isActive': true,
  'createdAt': '2026-06-02T20:00:00Z',
  'updatedAt': null,
};

Uint8List _jpegBytes() => Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]);
