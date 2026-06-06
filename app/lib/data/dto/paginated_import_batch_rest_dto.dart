import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import 'import_batch_rest_dto.dart';

final class PaginatedImportBatchRestDto {
  const PaginatedImportBatchRestDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasNextPage,
  });

  final List<ImportBatchRestDto> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasNextPage;

  factory PaginatedImportBatchRestDto.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      throw _invalidPaginatedField('items', json);
    }

    return PaginatedImportBatchRestDto(
      items: items
          .map(
            (item) => ImportBatchRestDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      total: _requiredInt(json, 'total'),
      page: _requiredInt(json, 'page'),
      pageSize: _requiredInt(json, 'pageSize'),
      hasNextPage: _requiredBool(json, 'hasNextPage'),
    );
  }
}

int _requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is int) return value;
  throw _invalidPaginatedField(field, json);
}

bool _requiredBool(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is bool) return value;
  throw _invalidPaginatedField(field, json);
}

AppException _invalidPaginatedField(String field, Map<String, dynamic> json) {
  return AppException(
    code: AppErrorCode.unexpected,
    message: 'Invalid import batches page response: field "$field" is invalid.',
    details: {'received': json},
  );
}
