import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/auth_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/auth_user_mapper.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';

void main() {
  group('AuthUserMapper.toDomain', () {
    test('maps admin user with branchIds and updatedAt', () {
      const dto = UserDto(
        id: 'user_admin_001',
        name: 'María Rodríguez',
        email: 'admin@inventario-demo.com',
        role: 'admin',
        branchIds: ['branch_central', 'branch_north'],
        isActive: true,
        createdAt: '2026-06-02T20:00:00Z',
        updatedAt: '2026-06-03T21:00:00Z',
      );

      final user = AuthUserMapper.toDomain(dto);

      expect(user.id, 'user_admin_001');
      expect(user.role, UserRole.admin);
      expect(user.branchIds, ['branch_central', 'branch_north']);
      expect(user.createdAt, DateTime.utc(2026, 6, 2, 20, 0, 0));
      expect(user.updatedAt, DateTime.utc(2026, 6, 3, 21, 0, 0));
      expect(user.isActive, isTrue);
    });

    test('maps collaborator user with empty branchIds and null updatedAt', () {
      const dto = UserDto(
        id: 'user_collaborator_001',
        name: 'Carlos',
        email: 'colaborador@inventario-demo.com',
        role: 'collaborator',
        branchIds: <String>[],
        isActive: true,
        createdAt: '2026-06-02T20:00:00Z',
        updatedAt: null,
      );

      final user = AuthUserMapper.toDomain(dto);

      expect(user.role, UserRole.collaborator);
      expect(user.branchIds, isEmpty);
      expect(user.updatedAt, isNull);
    });

    test('throws AppException for unknown role values', () {
      const dto = UserDto(
        id: 'u1',
        name: 'n',
        email: 'x@y.com',
        role: 'super_admin',
        branchIds: <String>[],
        isActive: true,
        createdAt: '2026-06-02T20:00:00Z',
        updatedAt: null,
      );

      expect(
        () => AuthUserMapper.toDomain(dto),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });

    test('throws AppException for invalid createdAt', () {
      const dto = UserDto(
        id: 'u1',
        name: 'n',
        email: 'x@y.com',
        role: 'admin',
        branchIds: <String>[],
        isActive: true,
        createdAt: 'not-a-date',
        updatedAt: null,
      );

      expect(() => AuthUserMapper.toDomain(dto), throwsA(isA<AppException>()));
    });
  });
}
