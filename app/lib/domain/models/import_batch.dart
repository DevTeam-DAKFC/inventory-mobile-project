/// Lifecycle status of a CSV product import batch.
enum ImportStatus {
  pending,
  processing,
  completed,
  failed,
  completedWithErrors,
}

/// Per-row validation error detected during a CSV import.
final class ImportBatchError {
  const ImportBatchError({
    required this.id,
    required this.batchId,
    required this.rowNumber,
    required this.field,
    required this.code,
    required this.message,
    this.rawValue,
  });

  final String id;
  final String batchId;
  final int rowNumber;
  final String field;
  final String code;
  final String message;
  final String? rawValue;
}

/// CSV product import batch.
final class ImportBatch {
  const ImportBatch({
    required this.id,
    required this.fileName,
    required this.importedBy,
    required this.status,
    required this.totalRows,
    required this.processedRows,
    required this.importedRows,
    required this.failedRows,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String fileName;
  final String importedBy;
  final ImportStatus status;
  final int totalRows;
  final int processedRows;
  final int importedRows;
  final int failedRows;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get hasErrors => failedRows > 0;
}
