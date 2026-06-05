import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_stock_data_source.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

const _developmentBranchId = '10000000-0000-0000-0000-000000000001';

Response<dynamic> _okResponse(dynamic data) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/stock'),
  statusCode: 200,
  data: data,
);

DioException _dioException(DioExceptionType type, {int? statusCode}) {
  final requestOptions = RequestOptions(path: '/stock');
  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
          ),
  );
}

Map<String, dynamic> _stockJson() => <String, dynamic>{
  'id': 'stock-guid',
  'availableQuantity': 4,
  'minStock': 5,
  'isLowStock': true,
  'lastMovementAt': null,
  'updatedAt': '2026-06-04T00:00:00Z',
  'product': <String, dynamic>{
    'id': 'product-guid',
    'name': 'Coffee Beans',
    'sku': 'COF-001',
    'barcode': null,
    'category': 'Coffee',
    'imageUrl': null,
  },
  'branch': <String, dynamic>{
    'id': 'branch-guid',
    'name': 'Central Branch',
    'address': 'Main street',
  },
};

void main() {
  late _MockDio dio;
  late RestApiStockDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiStockDataSource(dio);
  });

  group('fetchStockByBranch', () {
    test(
      'sends branchId as query parameter and parses an array response',
      () async {
        when(
          () => dio.get<dynamic>(
            '/stock',
            queryParameters: {'branchId': _developmentBranchId},
          ),
        ).thenAnswer((_) async => _okResponse([_stockJson()]));

        final result = await sut.fetchStockByBranch(_developmentBranchId);

        expect(result, hasLength(1));
        expect(result.single.productName, 'Coffee Beans');
        expect(result.single.branchName, 'Central Branch');
        expect(result.single.availableQuantity, 4);
        expect(result.single.isLowStock, isTrue);
      },
    );

    test('parses a paginated response with items', () async {
      when(
        () => dio.get<dynamic>(
          '/stock',
          queryParameters: {'branchId': _developmentBranchId},
        ),
      ).thenAnswer(
        (_) async => _okResponse(<String, dynamic>{
          'items': [_stockJson()],
          'page': 1,
          'pageSize': 20,
        }),
      );

      final result = await sut.fetchStockByBranch(_developmentBranchId);

      expect(result.single.id, 'stock-guid');
    });

    test('maps connectionTimeout to AppErrorCode.timeout', () async {
      when(
        () => dio.get<dynamic>(
          '/stock',
          queryParameters: {'branchId': _developmentBranchId},
        ),
      ).thenThrow(_dioException(DioExceptionType.connectionTimeout));

      await expectLater(
        sut.fetchStockByBranch(_developmentBranchId),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.timeout,
          ),
        ),
      );
    });

    test('maps 403 badResponse to AppErrorCode.forbidden', () async {
      when(
        () => dio.get<dynamic>(
          '/stock',
          queryParameters: {'branchId': _developmentBranchId},
        ),
      ).thenThrow(_dioException(DioExceptionType.badResponse, statusCode: 403));

      await expectLater(
        sut.fetchStockByBranch(_developmentBranchId),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.forbidden,
          ),
        ),
      );
    });

    test('maps invalid JSON shape to AppErrorCode.unexpected', () async {
      when(
        () => dio.get<dynamic>(
          '/stock',
          queryParameters: {'branchId': _developmentBranchId},
        ),
      ).thenAnswer((_) async => _okResponse(<String, dynamic>{'items': 'bad'}));

      await expectLater(
        sut.fetchStockByBranch(_developmentBranchId),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });
  });
}
