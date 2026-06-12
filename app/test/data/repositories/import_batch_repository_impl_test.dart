import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_import_batch_data_source.dart';
import 'package:inventory_mobile/data/dto/import_batch_rest_dto.dart';
import 'package:inventory_mobile/data/dto/paginated_import_batch_error_rest_dto.dart';
import 'package:inventory_mobile/data/dto/paginated_import_batch_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/import_batch_repository_impl.dart';
import 'package:inventory_mobile/domain/models/import_batch.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';
import 'package:inventory_mobile/domain/models/product_import_file.dart';
import 'package:mocktail/mocktail.dart';

class _MockImportBatchDataSource extends Mock
    implements RestApiImportBatchDataSource {}

ImportBatchRestDto _batchDto({String status = 'completed'}) {
  return ImportBatchRestDto(
    id: 'batch-id',
    fileName: 'products.csv',
    importedBy: 'user-id',
    status: status,
    totalRows: 3,
    processedRows: 3,
    importedRows: 3,
    failedRows: 0,
    createdAt: DateTime.utc(2026, 6, 5, 20),
    completedAt: DateTime.utc(2026, 6, 5, 20, 1),
  );
}

void main() {
  late _MockImportBatchDataSource dataSource;
  late ImportBatchRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(
      const ProductImportFile(fileName: 'products.csv', bytes: [1, 2, 3]),
    );
  });

  setUp(() {
    dataSource = _MockImportBatchDataSource();
    sut = ImportBatchRepositoryImpl(dataSource);
  });

  group('uploadProductCsv', () {
    test('returns AppSuccess with mapped import batch', () async {
      when(
        () => dataSource.uploadProductCsv(any()),
      ).thenAnswer((_) async => _batchDto(status: 'completed_with_errors'));

      final result = await sut.uploadProductCsv(
        const ProductImportFile(fileName: 'products.csv', bytes: [1, 2, 3]),
      );

      expect(result, isA<AppSuccess<ImportBatch>>());
      expect(result.dataOrNull?.status, ImportStatus.completedWithErrors);
    });

    test('preserves AppException failures from the data source', () async {
      const exception = AppException(
        code: AppErrorCode.validationError,
        message: 'Invalid CSV file.',
      );
      when(() => dataSource.uploadProductCsv(any())).thenThrow(exception);

      final result = await sut.uploadProductCsv(
        const ProductImportFile(fileName: 'products.csv', bytes: [1, 2, 3]),
      );

      expect(result, isA<AppFailure<ImportBatch>>());
      expect(result.exceptionOrNull, same(exception));
    });
  });

  group('getImportBatches', () {
    test('returns AppSuccess with mapped paginated batches', () async {
      when(() => dataSource.getImportBatches(page: 2, pageSize: 10)).thenAnswer(
        (_) async => PaginatedImportBatchRestDto(
          items: [_batchDto()],
          total: 1,
          page: 2,
          pageSize: 10,
          hasNextPage: false,
        ),
      );

      final result = await sut.getImportBatches(page: 2, pageSize: 10);

      expect(result, isA<AppSuccess<PaginatedResult<ImportBatch>>>());
      expect(result.dataOrNull?.page, 2);
      expect(result.dataOrNull?.items.single.fileName, 'products.csv');
    });
  });

  group('getImportBatchById', () {
    test('returns AppFailure unexpected for non-AppException errors', () async {
      when(
        () => dataSource.getImportBatchById('batch-id'),
      ).thenThrow(StateError('boom'));

      final result = await sut.getImportBatchById('batch-id');

      expect(result, isA<AppFailure<ImportBatch>>());
      expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
      expect(result.exceptionOrNull?.cause, isA<StateError>());
    });
  });

  group('getImportBatchErrors', () {
    test('returns AppSuccess with mapped paginated errors', () async {
      when(
        () =>
            dataSource.getImportBatchErrors('batch-id', page: 1, pageSize: 20),
      ).thenAnswer(
        (_) async => const PaginatedImportBatchErrorRestDto(
          items: [
            ImportBatchErrorRestDto(
              id: 'error-id',
              batchId: 'batch-id',
              rowNumber: 2,
              field: 'sku',
              code: 'duplicate_sku',
              message: 'SKU already exists.',
              rawValue: 'RICE-001',
            ),
          ],
          total: 1,
          page: 1,
          pageSize: 20,
          hasNextPage: false,
        ),
      );

      final result = await sut.getImportBatchErrors('batch-id');

      expect(result, isA<AppSuccess<PaginatedResult<ImportBatchError>>>());
      expect(result.dataOrNull?.items.single.code, 'duplicate_sku');
    });
  });
}
