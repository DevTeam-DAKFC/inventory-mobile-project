import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

/// Wire-level payload for `POST /auth/register`.
final class AuthRegisterRequestDto {
  const AuthRegisterRequestDto({
    required this.name,
    required this.email,
    required this.password,
    this.role,
    this.branchIds,
  });

  final String name;
  final String email;
  final String password;
  final String? role;
  final List<String>? branchIds;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        if (role != null) 'role': role,
        if (branchIds != null) 'branchIds': branchIds,
      };
}

/// Wire-level payload for `POST /auth/login`.
final class AuthLoginRequestDto {
  const AuthLoginRequestDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Wire-level user object embedded in auth responses and returned by
/// `GET /auth/me`.
final class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branchIds,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> branchIds;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final role = json['role'];
    final isActive = json['isActive'];
    final createdAt = json['createdAt'];

    if (id is! String) {
      throw _invalid('user.id', json);
    }
    if (name is! String) {
      throw _invalid('user.name', json);
    }
    if (email is! String) {
      throw _invalid('user.email', json);
    }
    if (role is! String) {
      throw _invalid('user.role', json);
    }
    if (isActive is! bool) {
      throw _invalid('user.isActive', json);
    }
    if (createdAt is! String) {
      throw _invalid('user.createdAt', json);
    }

    final updatedAtRaw = json['updatedAt'];
    final String? updatedAt;
    if (updatedAtRaw == null) {
      updatedAt = null;
    } else if (updatedAtRaw is String) {
      updatedAt = updatedAtRaw;
    } else {
      throw _invalid('user.updatedAt', json);
    }

    final branchIdsRaw = json['branchIds'];
    final List<String> branchIds;
    if (branchIdsRaw == null) {
      branchIds = const [];
    } else if (branchIdsRaw is List) {
      branchIds = <String>[];
      for (final entry in branchIdsRaw) {
        if (entry is! String) {
          throw _invalid('user.branchIds[*]', json);
        }
        branchIds.add(entry);
      }
    } else {
      throw _invalid('user.branchIds', json);
    }

    return UserDto(
      id: id,
      name: name,
      email: email,
      role: role,
      branchIds: branchIds,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static AppException _invalid(String field, Object received) {
    return AppException(
      code: AppErrorCode.unexpected,
      message: 'Invalid user payload: field "$field" is missing or has the '
          'wrong type.',
      details: {'received': received},
    );
  }
}

/// Wire-level payload returned by `POST /auth/login` and `POST /auth/register`.
final class AuthLoginResponseDto {
  const AuthLoginResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserDto user;

  factory AuthLoginResponseDto.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    final tokenType = json['tokenType'];
    final expiresIn = json['expiresIn'];
    final user = json['user'];

    if (accessToken is! String) {
      throw _invalid('accessToken', json);
    }
    if (tokenType is! String) {
      throw _invalid('tokenType', json);
    }
    if (expiresIn is! int) {
      throw _invalid('expiresIn', json);
    }
    if (user is! Map) {
      throw _invalid('user', json);
    }

    return AuthLoginResponseDto(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      user: UserDto.fromJson(Map<String, dynamic>.from(user)),
    );
  }

  static AppException _invalid(String field, Object received) {
    return AppException(
      code: AppErrorCode.unexpected,
      message: 'Invalid auth response: field "$field" is missing or has the '
          'wrong type.',
      details: {'received': received},
    );
  }
}
