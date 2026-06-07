import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

final class StockLookupRestDto {
  const StockLookupRestDto({
    required this.id,
    required this.availableQuantity,
    required this.minStock,
    required this.isLowStock,
    required this.product,
    required this.branch,
    this.lastMovementAt,
    this.updatedAt,
  });

  final String id;
  final int availableQuantity;
  final int minStock;
  final bool isLowStock;
  final DateTime? lastMovementAt;
  final DateTime? updatedAt;
  final StockLookupProductRestDto product;
  final StockLookupBranchRestDto branch;

  factory StockLookupRestDto.fromJson(Map<String, dynamic> json) {
    return StockLookupRestDto(
      id: _requiredString(json, 'id'),
      availableQuantity: _requiredInt(json, 'availableQuantity'),
      minStock: _requiredInt(json, 'minStock'),
      isLowStock: _requiredBool(json, 'isLowStock'),
      lastMovementAt: _optionalDateTime(json, 'lastMovementAt'),
      updatedAt: _optionalDateTime(json, 'updatedAt'),
      product: StockLookupProductRestDto.fromJson(
        _requiredMap(json, 'product'),
      ),
      branch: StockLookupBranchRestDto.fromJson(_requiredMap(json, 'branch')),
    );
  }
}

final class StockLookupProductRestDto {
  const StockLookupProductRestDto({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    this.barcode,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String sku;
  final String category;
  final String? barcode;
  final String? imageUrl;

  factory StockLookupProductRestDto.fromJson(Map<String, dynamic> json) {
    return StockLookupProductRestDto(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      sku: _requiredString(json, 'sku'),
      category: _requiredString(json, 'category'),
      barcode: _optionalString(json, 'barcode'),
      imageUrl: _optionalString(json, 'imageUrl'),
    );
  }
}

final class StockLookupBranchRestDto {
  const StockLookupBranchRestDto({
    required this.id,
    required this.name,
    this.address,
  });

  final String id;
  final String name;
  final String? address;

  factory StockLookupBranchRestDto.fromJson(Map<String, dynamic> json) {
    return StockLookupBranchRestDto(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      address: _optionalString(json, 'address'),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is String && value.isNotEmpty) return value;
  throw _invalidStockField(field, json);
}

String? _optionalString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is String) return value;
  throw _invalidStockField(field, json);
}

int _requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is int) return value;
  throw _invalidStockField(field, json);
}

bool _requiredBool(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is bool) return value;
  throw _invalidStockField(field, json);
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is Map) return Map<String, dynamic>.from(value);
  throw _invalidStockField(field, json);
}

DateTime? _optionalDateTime(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw _invalidStockField(field, json);
}

AppException _invalidStockField(String field, Map<String, dynamic> json) {
  return AppException(
    code: AppErrorCode.unexpected,
    message: 'Invalid stock lookup response: field "$field" is invalid.',
    details: {'received': json},
  );
}
