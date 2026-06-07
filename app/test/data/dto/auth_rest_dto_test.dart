import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/auth_rest_dto.dart';

void main() {
  group('UserDto.fromJson', () {
    test('parses a valid user payload (with updatedAt)', () {
      final dto = UserDto.fromJson(<String, dynamic>{
        'id': 'user_admin_001',
        'name': 'María Rodríguez',
        'email': 'admin@inventario-demo.com',
        'role': 'admin',
        'branchIds': ['branch_central', 'branch_north'],
        'isActive': true,
        'createdAt': '2026-06-02T20:00:00Z',
        'updatedAt': '2026-06-03T21:00:00Z',
      });

      expect(dto.id, 'user_admin_001');
      expect(dto.role, 'admin');
      expect(dto.branchIds, ['branch_central', 'branch_north']);
      expect(dto.isActive, true);
      expect(dto.updatedAt, '2026-06-03T21:00:00Z');
    });

    test('parses a payload with null updatedAt and empty branchIds', () {
      final dto = UserDto.fromJson(<String, dynamic>{
        'id': 'user_collaborator_001',
        'name': 'Carlos Pérez',
        'email': 'colaborador@inventario-demo.com',
        'role': 'collaborator',
        'branchIds': <String>[],
        'isActive': true,
        'createdAt': '2026-06-02T20:00:00Z',
        'updatedAt': null,
      });

      expect(dto.branchIds, isEmpty);
      expect(dto.updatedAt, isNull);
    });

    test('throws AppException when a required field is missing', () {
      expect(
        () => UserDto.fromJson(<String, dynamic>{
          'id': 'u1',
          'email': 'x@y.com',
          'role': 'admin',
          'isActive': true,
          'createdAt': '2026-06-02T20:00:00Z',
        }),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });

    test('throws AppException when branchIds entry is not a string', () {
      expect(
        () => UserDto.fromJson(<String, dynamic>{
          'id': 'u1',
          'name': 'n',
          'email': 'x@y.com',
          'role': 'admin',
          'branchIds': [1, 2],
          'isActive': true,
          'createdAt': '2026-06-02T20:00:00Z',
        }),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('AuthLoginResponseDto.fromJson', () {
    Map<String, dynamic> validUserJson() => <String, dynamic>{
      'id': 'user_admin_001',
      'name': 'María Rodríguez',
      'email': 'admin@inventario-demo.com',
      'role': 'admin',
      'branchIds': ['branch_central'],
      'isActive': true,
      'createdAt': '2026-06-02T20:00:00Z',
      'updatedAt': null,
    };

    test('parses a valid login response', () {
      final dto = AuthLoginResponseDto.fromJson(<String, dynamic>{
        'accessToken': 'eyJabc.payload.sig',
        'tokenType': 'Bearer',
        'expiresIn': 3600,
        'user': validUserJson(),
      });

      expect(dto.accessToken, 'eyJabc.payload.sig');
      expect(dto.tokenType, 'Bearer');
      expect(dto.expiresIn, 3600);
      expect(dto.user.id, 'user_admin_001');
      expect(dto.user.role, 'admin');
    });

    test('throws AppException when accessToken is missing', () {
      expect(
        () => AuthLoginResponseDto.fromJson(<String, dynamic>{
          'tokenType': 'Bearer',
          'expiresIn': 3600,
          'user': validUserJson(),
        }),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });

    test('throws AppException when expiresIn is not an int', () {
      expect(
        () => AuthLoginResponseDto.fromJson(<String, dynamic>{
          'accessToken': 't',
          'tokenType': 'Bearer',
          'expiresIn': '3600',
          'user': validUserJson(),
        }),
        throwsA(isA<AppException>()),
      );
    });

    test('throws AppException when user is not an object', () {
      expect(
        () => AuthLoginResponseDto.fromJson(<String, dynamic>{
          'accessToken': 't',
          'tokenType': 'Bearer',
          'expiresIn': 3600,
          'user': 'not-an-object',
        }),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('AuthRegisterRequestDto.toJson', () {
    test('omits optional fields when null', () {
      const req = AuthRegisterRequestDto(
        name: 'Ana',
        email: 'ana@example.com',
        password: 'pw',
      );

      expect(req.toJson(), {
        'name': 'Ana',
        'email': 'ana@example.com',
        'password': 'pw',
      });
    });

    test('includes optional role and branchIds when set', () {
      const req = AuthRegisterRequestDto(
        name: 'Ana',
        email: 'ana@example.com',
        password: 'pw',
        role: 'collaborator',
        branchIds: ['branch_central'],
      );

      expect(req.toJson(), {
        'name': 'Ana',
        'email': 'ana@example.com',
        'password': 'pw',
        'role': 'collaborator',
        'branchIds': ['branch_central'],
      });
    });
  });

  group('AuthLoginRequestDto.toJson', () {
    test('serializes email and password', () {
      const req = AuthLoginRequestDto(email: 'ana@example.com', password: 'pw');

      expect(req.toJson(), {'email': 'ana@example.com', 'password': 'pw'});
    });
  });
}
