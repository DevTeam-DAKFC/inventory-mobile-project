import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

final class StockOverviewRestDto {
  const StockOverviewRestDto({
    required this.id,
    required this.productId,
    required this.productName,
    required this.branchId,
    required this.branchName,
    required this.availableQuantity,
    required this.minStock,
    required this.isLowStock,
    this.sku,
    this.productImageUrl,
    this.branchAddress,
    this.lastMovementAt,
    this.updatedAt,
  });

  final String id;
  final String productId;
  final String productName;
  final String? sku;
  final String? productImageUrl;
  final String branchId;
  final String branchName;
  final String? branchAddress;
  final int availableQuantity;
  final int minStock;
  final bool isLowStock;
  final DateTime? lastMovementAt;
  final DateTime? updatedAt;

  factory StockOverviewRestDto.fromJson(Map<String, dynamic> json) {
    try {
      final product = _mapOrEmpty(json['product']);
      final branch = _mapOrEmpty(json['branch']);
      final availableQuantity = _requiredInt(json, 'availableQuantity');
      final minStock =
          _intValue(json['minStock']) ?? _intValue(product['minStock']) ?? 0;

      return StockOverviewRestDto(
        id: _requiredString(json, 'id'),
        productId:
            _stringValue(json['productId']) ?? _requiredString(product, 'id'),
        productName: _stringValue(product['name']) ?? 'Producto sin nombre',
        sku: _stringValue(product['sku']),
        productImageUrl: _stringValue(product['imageUrl']),
        branchId:
            _stringValue(json['branchId']) ?? _requiredString(branch, 'id'),
        branchName: _stringValue(branch['name']) ?? 'Sucursal sin nombre',
        branchAddress: _stringValue(branch['address']),
        availableQuantity: availableQuantity,
        minStock: minStock,
        isLowStock:
            _boolValue(json['isLowStock']) ?? availableQuantity <= minStock,
        lastMovementAt: _dateTimeValue(json['lastMovementAt']),
        updatedAt: _dateTimeValue(json['updatedAt']),
      );
    } on AppException {
      rethrow;
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid stock response item.',
        cause: e,
        stackTrace: stack,
        details: {'item': json},
      );
    }
  }

  static Map<String, dynamic> _mapOrEmpty(Object? value) {
    if (value == null) {
      return const <String, dynamic>{};
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw AppException(
      code: AppErrorCode.unexpected,
      message: 'Invalid stock response: nested object is malformed.',
      details: {'received': value},
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = _stringValue(json[key]);
    if (value == null || value.isEmpty) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid stock response: missing "$key".',
        details: {'item': json},
      );
    }
    return value;
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = _intValue(json[key]);
    if (value == null) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid stock response: missing "$key".',
        details: {'item': json},
      );
    }
    return value;
  }

  static String? _stringValue(Object? value) => switch (value) {
    String text => text,
    _ => null,
  };

  static int? _intValue(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    _ => null,
  };

  static bool? _boolValue(Object? value) => switch (value) {
    bool flag => flag,
    _ => null,
  };

  static DateTime? _dateTimeValue(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
