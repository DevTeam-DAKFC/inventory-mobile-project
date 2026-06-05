/// Lifecycle status of a CSV product import batch.
enum ImportStatus { pending, validated, completed, failed }

/// Per-row validation error detected during a CSV import.
final class ImportBatchError {
  const ImportBatchError({
    required this.rowNumber,
    required this.field,
    required this.message,
  });

  final int rowNumber;
  final String field;
  final String message;
}

/// CSV product import batch.
final class ImportBatch {
  const ImportBatch({
    required this.id,
    required this.fileName,
    required this.status,
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
    required this.importedBy,
    required this.errors,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String fileName;
  final ImportStatus status;
  final int totalRows;
  final int validRows;
  final int invalidRows;
  final String importedBy;
  final List<ImportBatchError> errors;
  final DateTime createdAt;
  final DateTime? completedAt;
}
