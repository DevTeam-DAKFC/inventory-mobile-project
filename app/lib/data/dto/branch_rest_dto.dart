import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

/// Wire-level representation of `BranchResponse` from `GET /branches`.
final class BranchRestDto {
  const BranchRestDto({
    required this.id,
    required this.name,
    required this.isActive,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? address;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BranchRestDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['branchId'];
    final name = json['name'];
    final address = json['address'];
    final isActive = json['isActive'];

    if (rawId is! String && rawId is! num) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid branch response: field "id" is missing or has an invalid type.',
        details: {'received': json},
      );
    }
    if (name is! String) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid branch response: field "name" is missing or not a string.',
        details: {'received': json},
      );
    }
    if (address != null && address is! String) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid branch response: field "address" must be a string or null.',
        details: {'received': json},
      );
    }
    if (isActive is! bool) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid branch response: field "isActive" is missing or not a boolean.',
        details: {'received': json},
      );
    }

    return BranchRestDto(
      id: rawId.toString(),
      name: name,
      address: address,
      isActive: isActive,
      createdAt: _tryParseDate(json['createdAt']),
      updatedAt: _tryParseDate(json['updatedAt']),
    );
  }

  static DateTime? _tryParseDate(Object? value) {
    if (value == null) return null;
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
