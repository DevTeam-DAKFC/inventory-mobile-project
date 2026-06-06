import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

final class ImportBatchRestDto {
  const ImportBatchRestDto({
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
  final String status;
  final int totalRows;
  final int processedRows;
  final int importedRows;
  final int failedRows;
  final DateTime createdAt;
  final DateTime? completedAt;

  factory ImportBatchRestDto.fromJson(Map<String, dynamic> json) {
    return ImportBatchRestDto(
      id: _requiredString(json, 'id'),
      fileName: _requiredString(json, 'fileName'),
      importedBy: _requiredString(json, 'importedBy'),
      status: _requiredString(json, 'status'),
      totalRows: _requiredInt(json, 'totalRows'),
      processedRows: _requiredInt(json, 'processedRows'),
      importedRows: _requiredInt(json, 'importedRows'),
      failedRows: _requiredInt(json, 'failedRows'),
      createdAt: _requiredDateTime(json, 'createdAt'),
      completedAt: _optionalDateTime(json, 'completedAt'),
    );
  }
}

final class ImportBatchErrorRestDto {
  const ImportBatchErrorRestDto({
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

  factory ImportBatchErrorRestDto.fromJson(Map<String, dynamic> json) {
    return ImportBatchErrorRestDto(
      id: _requiredString(json, 'id'),
      batchId: _requiredString(json, 'batchId'),
      rowNumber: _requiredInt(json, 'rowNumber'),
      field: _requiredString(json, 'field'),
      code: _requiredString(json, 'code'),
      message: _requiredString(json, 'message'),
      rawValue: _optionalString(json, 'rawValue'),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is String && value.isNotEmpty) return value;
  throw _invalidField(field, json);
}

String? _optionalString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is String) return value;
  throw _invalidField(field, json);
}

int _requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is int) return value;
  throw _invalidField(field, json);
}

DateTime _requiredDateTime(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw _invalidField(field, json);
}

DateTime? _optionalDateTime(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw _invalidField(field, json);
}

AppException _invalidField(String field, Map<String, dynamic> json) {
  return AppException(
    code: AppErrorCode.unexpected,
    message: 'Invalid import batch response: field "$field" is invalid.',
    details: {'received': json},
  );
}
