import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_stock_lookup_data_source.dart';
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

Map<String, dynamic> _stockLookupJson() => {
  'id': 'stock-id',
  'availableQuantity': 12,
  'minStock': 10,
  'isLowStock': false,
  'lastMovementAt': '2026-06-05T12:00:00Z',
  'updatedAt': '2026-06-05T12:01:00Z',
  'product': {
    'id': 'product-id',
    'name': 'Rice 1kg',
    'sku': 'RICE-001',
    'category': 'Food',
  },
  'branch': {'id': 'branch-id', 'name': 'Central Branch'},
};

void main() {
  late _MockDio dio;
  late RestApiStockLookupDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiStockLookupDataSource(dio);
  });

  group('getStockLookup', () {
    test('loads stock lookup by product and branch', () async {
      const query = {'productId': 'product-id', 'branchId': 'branch-id'};
      when(
        () => dio.get<dynamic>('/stock/lookup', queryParameters: query),
      ).thenAnswer((_) async => _response('/stock/lookup', _stockLookupJson()));

      final dto = await sut.getStockLookup(
        productId: 'product-id',
        branchId: 'branch-id',
      );

      expect(dto.id, 'stock-id');
      expect(dto.availableQuantity, 12);
      expect(dto.product.name, 'Rice 1kg');
      verify(
        () => dio.get<dynamic>('/stock/lookup', queryParameters: query),
      ).called(1);
    });

    test('maps not_found response', () async {
      const query = {'productId': 'product-id', 'branchId': 'branch-id'};
      when(
        () => dio.get<dynamic>('/stock/lookup', queryParameters: query),
      ).thenThrow(
        _badResponse('/stock/lookup', 404, {
          'code': 'not_found',
          'message': 'Stock not found.',
        }),
      );

      await expectLater(
        sut.getStockLookup(productId: 'product-id', branchId: 'branch-id'),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.notFound,
          ),
        ),
      );
    });
  });
}
