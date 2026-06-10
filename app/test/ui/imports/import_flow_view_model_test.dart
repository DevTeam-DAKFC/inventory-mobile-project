import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/import_batch_providers.dart';
import 'package:inventory_mobile/domain/models/import_batch.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';
import 'package:inventory_mobile/domain/models/product_import_file.dart';
import 'package:inventory_mobile/domain/repositories/import_batch_repository.dart';
import 'package:inventory_mobile/ui/imports/import_flow_view_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockImportBatchRepository extends Mock
    implements ImportBatchRepository {}

ImportBatch _batch({int failedRows = 0, ImportStatus? status}) {
  return ImportBatch(
    id: 'batch-id',
    fileName: 'products.csv',
    importedBy: 'user-id',
    status:
        status ??
        (failedRows > 0
            ? ImportStatus.completedWithErrors
            : ImportStatus.completed),
    totalRows: 3,
    processedRows: 3,
    importedRows: 3 - failedRows,
    failedRows: failedRows,
    createdAt: DateTime.utc(2026, 6, 5, 20),
    completedAt: DateTime.utc(2026, 6, 5, 20, 1),
  );
}

const _file = ProductImportFile(
  fileName: 'products.csv',
  bytes: [110, 97, 109, 101],
);

void main() {
  late _MockImportBatchRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(_file);
  });

  setUp(() {
    repository = _MockImportBatchRepository();
    container = ProviderContainer(
      overrides: [importBatchRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('validates CSV extension when selecting a file', () {
    final viewModel = container.read(importFlowViewModelProvider.notifier);

    viewModel.selectFile(
      const ProductImportFile(fileName: 'products.txt', bytes: [1]),
    );

    final state = container.read(importFlowViewModelProvider);
    expect(state.selectedFile, isNull);
    expect(state.errorCode, AppErrorCode.validationError);
    expect(state.errorMessage, 'Only CSV files can be uploaded.');
  });

  test('validates file selection before submit', () async {
    final viewModel = container.read(importFlowViewModelProvider.notifier);

    await viewModel.submit();

    final state = container.read(importFlowViewModelProvider);
    expect(state.errorCode, AppErrorCode.validationError);
    expect(state.errorMessage, 'Please select a CSV file before uploading.');
    verifyNever(() => repository.uploadProductCsv(any()));
  });

  test('uploads CSV and stores successful batch', () async {
    when(
      () => repository.uploadProductCsv(any()),
    ).thenAnswer((_) async => AppSuccess(_batch()));

    final viewModel = container.read(importFlowViewModelProvider.notifier)
      ..selectFile(_file);

    await viewModel.submit();

    final state = container.read(importFlowViewModelProvider);
    expect(state.isUploading, isFalse);
    expect(state.selectedFile, isNull);
    expect(state.createdBatch?.id, 'batch-id');
    expect(state.batchErrors, isEmpty);
    expect(state.successMessage, 'Importación completada correctamente.');
    verify(() => repository.uploadProductCsv(_file)).called(1);
    verifyNever(
      () => repository.getImportBatchErrors(
        any(),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    );
  });

  test('loads batch errors when upload completes with failed rows', () async {
    const error = ImportBatchError(
      id: 'error-id',
      batchId: 'batch-id',
      rowNumber: 2,
      field: 'sku',
      code: 'duplicate_sku',
      message: 'SKU already exists.',
    );
    when(
      () => repository.uploadProductCsv(any()),
    ).thenAnswer((_) async => AppSuccess(_batch(failedRows: 1)));
    when(() => repository.getImportBatchErrors('batch-id')).thenAnswer(
      (_) async => const AppSuccess(
        PaginatedResult<ImportBatchError>(
          items: [error],
          page: 1,
          pageSize: 20,
          totalCount: 1,
        ),
      ),
    );

    final viewModel = container.read(importFlowViewModelProvider.notifier)
      ..selectFile(_file);

    await viewModel.submit();

    final state = container.read(importFlowViewModelProvider);
    expect(state.createdBatch?.hasErrors, isTrue);
    expect(state.selectedFile, isNull);
    expect(state.successMessage, isNull);
    expect(state.batchErrors, [error]);
    verify(() => repository.getImportBatchErrors('batch-id')).called(1);
  });

  test('does not show a success message when the batch failed', () async {
    when(() => repository.uploadProductCsv(any())).thenAnswer(
      (_) async =>
          AppSuccess(_batch(failedRows: 3, status: ImportStatus.failed)),
    );
    when(() => repository.getImportBatchErrors('batch-id')).thenAnswer(
      (_) async => const AppSuccess(
        PaginatedResult<ImportBatchError>(
          items: [],
          page: 1,
          pageSize: 20,
          totalCount: 0,
        ),
      ),
    );

    final viewModel = container.read(importFlowViewModelProvider.notifier)
      ..selectFile(_file);

    await viewModel.submit();

    final state = container.read(importFlowViewModelProvider);
    expect(state.createdBatch?.status, ImportStatus.failed);
    expect(state.selectedFile, isNull);
    expect(state.successMessage, isNull);
    verify(() => repository.getImportBatchErrors('batch-id')).called(1);
  });

  test('clears the current import result', () async {
    when(() => repository.uploadProductCsv(any())).thenAnswer(
      (_) async =>
          AppSuccess(_batch(failedRows: 3, status: ImportStatus.failed)),
    );
    when(() => repository.getImportBatchErrors('batch-id')).thenAnswer(
      (_) async => const AppSuccess(
        PaginatedResult<ImportBatchError>(
          items: [],
          page: 1,
          pageSize: 20,
          totalCount: 0,
        ),
      ),
    );

    final viewModel = container.read(importFlowViewModelProvider.notifier)
      ..selectFile(_file);

    await viewModel.submit();
    viewModel.clear();

    final state = container.read(importFlowViewModelProvider);
    expect(state.selectedFile, isNull);
    expect(state.createdBatch, isNull);
    expect(state.batchErrors, isEmpty);
    expect(state.errorMessage, isNull);
    expect(state.successMessage, isNull);
  });

  test('shows backend upload failure', () async {
    const exception = AppException(
      code: AppErrorCode.validationError,
      message: 'Invalid CSV file.',
    );
    when(
      () => repository.uploadProductCsv(any()),
    ).thenAnswer((_) async => const AppFailure(exception));

    final viewModel = container.read(importFlowViewModelProvider.notifier)
      ..selectFile(_file);

    await viewModel.submit();

    final state = container.read(importFlowViewModelProvider);
    expect(state.isUploading, isFalse);
    expect(state.createdBatch, isNull);
    expect(state.errorCode, AppErrorCode.validationError);
    expect(state.errorMessage, 'Invalid CSV file.');
  });
}
