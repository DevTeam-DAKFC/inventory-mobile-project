import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

final class NotificationTokenRestDto {
  const NotificationTokenRestDto({
    required this.id,
    required this.token,
    required this.platform,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String token;
  final String platform;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory NotificationTokenRestDto.fromJson(Map<String, dynamic> json) {
    return NotificationTokenRestDto(
      id: _requiredString(json, 'id'),
      token: _requiredString(json, 'token'),
      platform: _requiredString(json, 'platform'),
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
    message: 'Invalid notification token response: field "$field" is invalid.',
    details: {'received': json},
  );
}
