import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

final class ProductRestDto {
  const ProductRestDto({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.minStock,
    required this.isActive,
    required this.createdAt,
    this.barcode,
    this.description,
    this.imageUrl,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final String category;
  final String? description;
  final String? imageUrl;
  final int minStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory ProductRestDto.fromJson(Map<String, dynamic> json) {
    return ProductRestDto(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      sku: _requiredString(json, 'sku'),
      barcode: _optionalString(json, 'barcode'),
      category: _requiredString(json, 'category'),
      description: _optionalString(json, 'description'),
      imageUrl: _optionalString(json, 'imageUrl'),
      minStock: _requiredInt(json, 'minStock'),
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

int _requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is int) return value;
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
    message: 'Invalid product response: field "$field" is invalid.',
    details: {'received': json},
  );
}
