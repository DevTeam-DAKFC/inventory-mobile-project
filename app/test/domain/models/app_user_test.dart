import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';

void main() {
  group('UserRole', () {
    test('exposes admin and collaborator', () {
      expect(UserRole.values, [UserRole.admin, UserRole.collaborator]);
    });
  });

  group('AppUser', () {
    test('can be constructed with required fields and preserves values', () {
      final createdAt = DateTime.utc(2026, 6, 2, 20);
      final user = AppUser(
        id: 'user_admin_001',
        name: 'María Rodríguez',
        email: 'admin@inventario-demo.com',
        role: UserRole.admin,
        branchIds: const ['branch_central', 'branch_north'],
        isActive: true,
        createdAt: createdAt,
      );

      expect(user.id, 'user_admin_001');
      expect(user.name, 'María Rodríguez');
      expect(user.email, 'admin@inventario-demo.com');
      expect(user.role, UserRole.admin);
      expect(user.branchIds, ['branch_central', 'branch_north']);
      expect(user.isActive, isTrue);
      expect(user.createdAt, createdAt);
      expect(user.updatedAt, isNull);
    });

    test('preserves optional updatedAt', () {
      final updatedAt = DateTime.utc(2026, 6, 3, 12);
      final user = AppUser(
        id: 'user_001',
        name: 'Carlos',
        email: 'carlos@example.com',
        role: UserRole.collaborator,
        branchIds: const [],
        isActive: true,
        createdAt: DateTime.utc(2026, 6, 2, 20),
        updatedAt: updatedAt,
      );

      expect(user.updatedAt, updatedAt);
    });
  });
}
