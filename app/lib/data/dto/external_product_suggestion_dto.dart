import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

/// Wire-level response returned by `GET /product-lookup/{barcode}`.
final class ExternalProductSuggestionDto {
  const ExternalProductSuggestionDto({
    required this.barcode,
    required this.source,
    this.name,
    this.brand,
    this.category,
    this.imageUrl,
  });

  final String barcode;
  final String? name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final String source;

  factory ExternalProductSuggestionDto.fromJson(Map<String, dynamic> json) {
    return ExternalProductSuggestionDto(
      barcode: _requiredString(json, 'barcode'),
      source: _requiredString(json, 'source'),
      name: _optionalString(json, 'name'),
      brand: _optionalString(json, 'brand'),
      category: _optionalString(json, 'category'),
      imageUrl: _optionalString(json, 'imageUrl'),
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

  static AppException _invalidField(
    Map<String, dynamic> json,
    String field,
    String expected,
  ) {
    return AppException(
      code: AppErrorCode.unexpected,
      message:
          'Invalid product lookup response: field "$field" must be $expected.',
      details: {'received': json},
    );
  }
}
