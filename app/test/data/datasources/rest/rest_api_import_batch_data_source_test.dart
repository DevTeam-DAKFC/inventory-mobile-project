import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_import_batch_data_source.dart';
import 'package:inventory_mobile/domain/models/product_import_file.dart';
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

Map<String, dynamic> _batchJson({String id = 'batch-id'}) => {
  'id': id,
  'fileName': 'products.csv',
  'importedBy': 'user-id',
  'status': 'completed',
  'totalRows': 3,
  'processedRows': 3,
  'importedRows': 3,
  'failedRows': 0,
  'createdAt': '2026-06-05T20:00:00Z',
  'completedAt': '2026-06-05T20:01:00Z',
};

Map<String, dynamic> _errorJson({String id = 'error-id'}) => {
  'id': id,
  'batchId': 'batch-id',
  'rowNumber': 2,
  'field': 'sku',
  'code': 'duplicate_sku',
  'message': 'SKU already exists.',
  'rawValue': 'RICE-001',
};

void main() {
  late _MockDio dio;
  late RestApiImportBatchDataSource sut;

  setUpAll(() {
    registerFallbackValue(FormData());
  });

  setUp(() {
    dio = _MockDio();
    sut = RestApiImportBatchDataSource(dio);
  });

  group('uploadProductCsv', () {
    test('posts multipart form data and returns import batch DTO', () async {
      const file = ProductImportFile(
        fileName: 'products.csv',
        bytes: [110, 97, 109, 101],
      );
      when(
        () => dio.post<dynamic>(
          '/import-batches/products',
          data: any(named: 'data', that: isA<FormData>()),
        ),
      ).thenAnswer(
        (_) async => _response(
          '/import-batches/products',
          _batchJson(),
          statusCode: 201,
        ),
      );

      final dto = await sut.uploadProductCsv(file);

      expect(dto.id, 'batch-id');
      final captured =
          verify(
                () => dio.post<dynamic>(
                  '/import-batches/products',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as FormData;
      expect(captured.files.single.key, 'file');
    });

    test('maps backend validation errors', () async {
      const file = ProductImportFile(
        fileName: 'products.csv',
        bytes: [110, 97, 109, 101],
      );
      when(
        () => dio.post<dynamic>(
          '/import-batches/products',
          data: any(named: 'data', that: isA<FormData>()),
        ),
      ).thenThrow(
        _badResponse('/import-batches/products', 400, {
          'code': 'validation_error',
          'message': 'Invalid CSV file.',
        }),
      );

      await expectLater(
        sut.uploadProductCsv(file),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.validationError,
          ),
        ),
      );
    });
  });

  group('getImportBatches', () {
    test('loads paginated import batches', () async {
      when(
        () => dio.get<dynamic>(
          '/import-batches',
          queryParameters: {'page': 2, 'pageSize': 10},
        ),
      ).thenAnswer(
        (_) async => _response('/import-batches', {
          'items': [_batchJson()],
          'total': 1,
          'page': 2,
          'pageSize': 10,
          'hasNextPage': false,
        }),
      );

      final dto = await sut.getImportBatches(page: 2, pageSize: 10);

      expect(dto.items, hasLength(1));
      expect(dto.page, 2);
    });
  });

  group('getImportBatchById', () {
    test('loads import batch detail by id', () async {
      when(() => dio.get<dynamic>('/import-batches/batch-id')).thenAnswer(
        (_) async =>
            _response('/import-batches/batch-id', _batchJson(id: 'batch-id')),
      );

      final dto = await sut.getImportBatchById('batch-id');

      expect(dto.id, 'batch-id');
    });
  });

  group('getImportBatchErrors', () {
    test('loads paginated import batch errors', () async {
      when(
        () => dio.get<dynamic>(
          '/import-batches/batch-id/errors',
          queryParameters: {'page': 1, 'pageSize': 20},
        ),
      ).thenAnswer(
        (_) async => _response('/import-batches/batch-id/errors', {
          'items': [_errorJson()],
          'total': 1,
          'page': 1,
          'pageSize': 20,
          'hasNextPage': false,
        }),
      );

      final dto = await sut.getImportBatchErrors('batch-id');

      expect(dto.items, hasLength(1));
      expect(dto.items.single.code, 'duplicate_sku');
    });
  });
}
