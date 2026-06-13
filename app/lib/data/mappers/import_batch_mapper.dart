import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/models/import_batch.dart';
import '../../domain/models/paginated_result.dart';
import '../dto/import_batch_rest_dto.dart';
import '../dto/paginated_import_batch_error_rest_dto.dart';
import '../dto/paginated_import_batch_rest_dto.dart';

final class ImportBatchMapper {
  const ImportBatchMapper._();

  static ImportBatch toDomain(ImportBatchRestDto dto) {
    return ImportBatch(
      id: dto.id,
      fileName: dto.fileName,
      importedBy: dto.importedBy,
      status: _statusFromWire(dto.status),
      totalRows: dto.totalRows,
      processedRows: dto.processedRows,
      importedRows: dto.importedRows,
      failedRows: dto.failedRows,
      createdAt: dto.createdAt,
      completedAt: dto.completedAt,
    );
  }

  static ImportBatchError errorToDomain(ImportBatchErrorRestDto dto) {
    return ImportBatchError(
      id: dto.id,
      batchId: dto.batchId,
      rowNumber: dto.rowNumber,
      field: dto.field,
      code: dto.code,
      message: dto.message,
      rawValue: dto.rawValue,
    );
  }

  static PaginatedResult<ImportBatch> toPaginatedDomain(
    PaginatedImportBatchRestDto dto,
  ) {
    return PaginatedResult(
      items: dto.items.map(toDomain).toList(),
      page: dto.page,
      pageSize: dto.pageSize,
      totalCount: dto.total,
    );
  }

  static PaginatedResult<ImportBatchError> errorsToPaginatedDomain(
    PaginatedImportBatchErrorRestDto dto,
  ) {
    return PaginatedResult(
      items: dto.items.map(errorToDomain).toList(),
      page: dto.page,
      pageSize: dto.pageSize,
      totalCount: dto.total,
    );
  }

  static ImportStatus _statusFromWire(String value) {
    return switch (value) {
      'pending' => ImportStatus.pending,
      'processing' => ImportStatus.processing,
      'completed' => ImportStatus.completed,
      'failed' => ImportStatus.failed,
      'completed_with_errors' => ImportStatus.completedWithErrors,
      _ => throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid import batch response: unknown status "$value".',
        details: {'status': value},
      ),
    };
  }
}
