import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

/// Wire-level representation of a Product response.
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

  static String _requiredString(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is String) return value;
    throw _invalidField(json, field, 'string');
  }

  static String? _optionalString(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null || value is String) return value as String?;
    throw _invalidField(json, field, 'string or null');
  }

  static int _requiredInt(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is int) return value;
    throw _invalidField(json, field, 'integer');
  }

  static bool _requiredBool(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is bool) return value;
    throw _invalidField(json, field, 'boolean');
  }

  static DateTime _requiredDateTime(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is String) {
      final parsed = _parseUtcDateTime(value);
      if (parsed != null) return parsed;
    }
    throw _invalidField(json, field, 'ISO-8601 date-time string');
  }

  static DateTime? _optionalDateTime(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return null;
    if (value is String) {
      final parsed = _parseUtcDateTime(value);
      if (parsed != null) return parsed;
    }
    throw _invalidField(json, field, 'ISO-8601 date-time string or null');
  }

  static DateTime? _parseUtcDateTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) return null;
    return parsed.toUtc();
  }

  static AppException _invalidField(
    Map<String, dynamic> json,
    String field,
    String expected,
  ) {
    return AppException(
      code: AppErrorCode.unexpected,
      message: 'Invalid product response: field "$field" must be $expected.',
      details: {'received': json},
    );
  }
}
