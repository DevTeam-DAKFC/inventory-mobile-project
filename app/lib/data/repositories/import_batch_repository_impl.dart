import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/import_batch.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product_import_file.dart';
import '../../domain/repositories/import_batch_repository.dart';
import '../datasources/rest/rest_api_import_batch_data_source.dart';
import '../mappers/import_batch_mapper.dart';

final class ImportBatchRepositoryImpl implements ImportBatchRepository {
  const ImportBatchRepositoryImpl(this._dataSource);

  final RestApiImportBatchDataSource _dataSource;

  @override
  Future<AppResult<ImportBatch>> uploadProductCsv(
    ProductImportFile file,
  ) async {
    try {
      final dto = await _dataSource.uploadProductCsv(file);
      return AppSuccess(ImportBatchMapper.toDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error uploading product import CSV.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<AppResult<PaginatedResult<ImportBatch>>> getImportBatches({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final dto = await _dataSource.getImportBatches(
        page: page,
        pageSize: pageSize,
      );
      return AppSuccess(ImportBatchMapper.toPaginatedDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading import batches.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<AppResult<ImportBatch>> getImportBatchById(String batchId) async {
    try {
      final dto = await _dataSource.getImportBatchById(batchId);
      return AppSuccess(ImportBatchMapper.toDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading import batch detail.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<AppResult<PaginatedResult<ImportBatchError>>> getImportBatchErrors(
    String batchId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final dto = await _dataSource.getImportBatchErrors(
        batchId,
        page: page,
        pageSize: pageSize,
      );
      return AppSuccess(ImportBatchMapper.errorsToPaginatedDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading import batch errors.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
