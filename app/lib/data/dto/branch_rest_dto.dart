import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

final class BranchRestDto {
  const BranchRestDto({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    this.address,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory BranchRestDto.fromJson(Map<String, dynamic> json) {
    return BranchRestDto(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      address: _optionalString(json, 'address'),
      isActive: _requiredBool(json, 'isActive'),
      createdAt: _requiredDateTime(json, 'createdAt'),
      updatedAt: _optionalDateTime(json, 'updatedAt'),
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

bool _requiredBool(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is bool) return value;
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
    message: 'Invalid branch response: field "$field" is invalid.',
    details: {'received': json},
  );
}
