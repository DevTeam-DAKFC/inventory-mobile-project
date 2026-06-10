import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/import_batch_providers.dart';
import 'package:inventory_mobile/domain/models/import_batch.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';
import 'package:inventory_mobile/domain/repositories/import_batch_repository.dart';
import 'package:inventory_mobile/ui/imports/import_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockImportBatchRepository extends Mock
    implements ImportBatchRepository {}

void main() {
  late _MockImportBatchRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockImportBatchRepository();
    container = ProviderContainer(
      overrides: [importBatchRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('importBatchListProvider', () {
    test('loads import batches through the repository', () async {
      const request = (page: 2, pageSize: 10);
      const page = PaginatedResult<ImportBatch>(
        items: [],
        page: 2,
        pageSize: 10,
        totalCount: 0,
      );
      when(
        () => repository.getImportBatches(page: 2, pageSize: 10),
      ).thenAnswer((_) async => const AppSuccess(page));

      final result = await container.read(
        importBatchListProvider(request).future,
      );

      expect(result.dataOrNull, page);
      verify(
        () => repository.getImportBatches(page: 2, pageSize: 10),
      ).called(1);
    });
  });

  group('importBatchDetailProvider', () {
    test('loads import batch detail through the repository', () async {
      final batch = ImportBatch(
        id: 'batch-id',
        fileName: 'products.csv',
        importedBy: 'user-id',
        status: ImportStatus.completed,
        totalRows: 1,
        processedRows: 1,
        importedRows: 1,
        failedRows: 0,
        createdAt: DateTime.utc(2026, 6, 5, 20),
      );
      when(
        () => repository.getImportBatchById('batch-id'),
      ).thenAnswer((_) async => AppSuccess(batch));

      final result = await container.read(
        importBatchDetailProvider('batch-id').future,
      );

      expect(result.dataOrNull, batch);
      verify(() => repository.getImportBatchById('batch-id')).called(1);
    });
  });

  group('importBatchErrorsProvider', () {
    test('loads import batch errors through the repository', () async {
      const request = (batchId: 'batch-id', page: 1, pageSize: 20);
      const page = PaginatedResult<ImportBatchError>(
        items: [
          ImportBatchError(
            id: 'error-id',
            batchId: 'batch-id',
            rowNumber: 2,
            field: 'sku',
            code: 'duplicate_sku',
            message: 'SKU already exists.',
          ),
        ],
        page: 1,
        pageSize: 20,
        totalCount: 1,
      );
      when(
        () =>
            repository.getImportBatchErrors('batch-id', page: 1, pageSize: 20),
      ).thenAnswer((_) async => const AppSuccess(page));

      final result = await container.read(
        importBatchErrorsProvider(request).future,
      );

      expect(result.dataOrNull, page);
      verify(
        () =>
            repository.getImportBatchErrors('batch-id', page: 1, pageSize: 20),
      ).called(1);
    });
  });
}
