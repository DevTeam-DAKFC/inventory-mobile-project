import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/models/app_user.dart';
import '../dto/auth_rest_dto.dart';

/// Translates [UserDto] from the backend into the domain-level [AppUser].
///
/// Keeps the wire-level role string and ISO date-time strings out of the
/// domain layer, and raises [AppException] when the backend sends a value
/// outside the documented contract.
final class AuthUserMapper {
  const AuthUserMapper._();

  static AppUser toDomain(UserDto dto) {
    return AppUser(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      role: _roleFromWire(dto.role, dto),
      branchIds: List<String>.unmodifiable(dto.branchIds),
      isActive: dto.isActive,
      createdAt: _parseDate(dto.createdAt, 'user.createdAt', dto),
      updatedAt: dto.updatedAt == null
          ? null
          : _parseDate(dto.updatedAt!, 'user.updatedAt', dto),
    );
  }

  static UserRole _roleFromWire(String wire, UserDto dto) {
    switch (wire) {
      case 'admin':
        return UserRole.admin;
      case 'collaborator':
        return UserRole.collaborator;
      default:
        throw AppException(
          code: AppErrorCode.unexpected,
          message: 'Invalid user payload: unknown role "$wire".',
          details: {'received': wire, 'userId': dto.id},
        );
    }
  }

  static DateTime _parseDate(String value, String field, UserDto dto) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid user payload: field "$field" is not a valid '
            'ISO-8601 date-time.',
        details: {'received': value, 'userId': dto.id},
      );
    }
    return parsed;
  }
}
