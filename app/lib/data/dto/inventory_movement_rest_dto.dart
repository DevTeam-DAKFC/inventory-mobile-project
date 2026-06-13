import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

final class InventoryMovementRestDto {
  const InventoryMovementRestDto({
    required this.id,
    required this.productId,
    required this.branchId,
    required this.userId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.resultingStock,
    required this.reason,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String productId;
  final String branchId;
  final String userId;
  final String type;
  final int quantity;
  final int previousStock;
  final int resultingStock;
  final String reason;
  final String? notes;
  final DateTime createdAt;

  factory InventoryMovementRestDto.fromJson(Map<String, dynamic> json) {
    return InventoryMovementRestDto(
      id: _requiredString(json, 'id'),
      productId: _requiredString(json, 'productId'),
      branchId: _requiredString(json, 'branchId'),
      userId: _requiredString(json, 'userId'),
      type: _requiredString(json, 'type'),
      quantity: _requiredInt(json, 'quantity'),
      previousStock: _requiredInt(json, 'previousStock'),
      resultingStock: _requiredInt(json, 'resultingStock'),
      reason: _requiredString(json, 'reason'),
      notes: _optionalString(json, 'notes'),
      createdAt: _requiredDateTime(json, 'createdAt'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'branchId': branchId,
    'userId': userId,
    'type': type,
    'quantity': quantity,
    'previousStock': previousStock,
    'resultingStock': resultingStock,
    'reason': reason,
    if (notes != null) 'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
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

AppException _invalidField(String field, Map<String, dynamic> json) {
  return AppException(
    code: AppErrorCode.unexpected,
    message: 'Invalid inventory movement response: field "$field" is invalid.',
    details: {'received': json},
  );
}
