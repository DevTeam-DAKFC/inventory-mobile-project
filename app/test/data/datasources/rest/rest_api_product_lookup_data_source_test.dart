import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_product_lookup_data_source.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late RestApiProductLookupDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiProductLookupDataSource(dio);
  });

  test('GET /product-lookup/{barcode} parses suggestion', () async {
    when(() => dio.get<dynamic>('/product-lookup/3017624010701')).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/product-lookup/3017624010701'),
        statusCode: 200,
        data: {
          'barcode': '3017624010701',
          'name': 'Nutella',
          'brand': 'Ferrero',
          'category': 'Spreads',
          'imageUrl': 'https://example.com/nutella.jpg',
          'source': 'open_food_facts',
        },
      ),
    );

    final result = await sut.lookupByBarcode('3017624010701');

    expect(result.name, 'Nutella');
    verify(() => dio.get<dynamic>('/product-lookup/3017624010701')).called(1);
  });

  test('maps a backend 404 without exposing DioException', () async {
    final request = RequestOptions(path: '/product-lookup/00000000');
    when(() => dio.get<dynamic>('/product-lookup/00000000')).thenThrow(
      DioException.badResponse(
        statusCode: 404,
        requestOptions: request,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: 404,
          data: {
            'error': {
              'code': 'product_not_found',
              'message': 'No suggestion found.',
            },
          },
        ),
      ),
    );

    await expectLater(
      sut.lookupByBarcode('00000000'),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          AppErrorCode.productNotFound,
        ),
      ),
    );
  });
}
