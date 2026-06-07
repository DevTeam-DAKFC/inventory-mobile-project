import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_product_data_source.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _response(String path, dynamic data, {int statusCode = 200}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );
}

DioException _badResponse(String path, int statusCode, dynamic data) {
  final requestOptions = RequestOptions(path: path);
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}

Map<String, dynamic> _productJson({bool isActive = true}) => {
  'id': 'product-id',
  'name': 'Rice 1kg',
  'sku': 'RICE-001',
  'category': 'Food',
  'minStock': 10,
  'isActive': isActive,
  'createdAt': '2026-06-05T20:00:00Z',
  'updatedAt': null,
};

void main() {
  late _MockDio dio;
  late RestApiProductDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiProductDataSource(dio);
  });

  group('getProducts', () {
    test('loads paginated products with active filter', () async {
      const query = {'isActive': true, 'page': 1, 'pageSize': 100};
      when(
        () => dio.get<dynamic>('/products', queryParameters: query),
      ).thenAnswer(
        (_) async => _response('/products', {
          'items': [_productJson()],
          'total': 1,
          'page': 1,
          'pageSize': 100,
          'hasNextPage': false,
        }),
      );

      final dto = await sut.getProducts(isActive: true);

      expect(dto.items, hasLength(1));
      expect(dto.items.single.name, 'Rice 1kg');
      verify(
        () => dio.get<dynamic>('/products', queryParameters: query),
      ).called(1);
    });

    test('maps backend failures', () async {
      const query = {'isActive': false, 'page': 1, 'pageSize': 100};
      when(
        () => dio.get<dynamic>('/products', queryParameters: query),
      ).thenThrow(
        _badResponse('/products', 401, {
          'code': 'unauthorized',
          'message': 'Unauthorized.',
        }),
      );

      await expectLater(
        sut.getProducts(isActive: false),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unauthorized,
          ),
        ),
      );
    });
  });

  group('activateProduct', () {
    test('patches activate endpoint', () async {
      when(
        () => dio.patch<dynamic>('/products/product-id/activate'),
      ).thenAnswer(
        (_) async => _response('/products/product-id/activate', null),
      );

      await sut.activateProduct('product-id');

      verify(
        () => dio.patch<dynamic>('/products/product-id/activate'),
      ).called(1);
    });
  });

  group('deactivateProduct', () {
    test('patches deactivate endpoint', () async {
      when(
        () => dio.patch<dynamic>('/products/product-id/deactivate'),
      ).thenAnswer(
        (_) async => _response('/products/product-id/deactivate', null),
      );

      await sut.deactivateProduct('product-id');

      verify(
        () => dio.patch<dynamic>('/products/product-id/deactivate'),
      ).called(1);
    });
  });
}
