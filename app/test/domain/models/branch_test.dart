import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/branch.dart';

void main() {
  group('Branch', () {
    test('can be constructed with required fields', () {
      final createdAt = DateTime.utc(2026, 6, 2, 20);
      final branch = Branch(
        id: 'branch_central',
        name: 'Sucursal Central',
        isActive: true,
        createdAt: createdAt,
      );

      expect(branch.id, 'branch_central');
      expect(branch.name, 'Sucursal Central');
      expect(branch.address, isNull);
      expect(branch.isActive, isTrue);
      expect(branch.createdAt, createdAt);
      expect(branch.updatedAt, isNull);
    });

    test('preserves optional address and updatedAt', () {
      final branch = Branch(
        id: 'branch_north',
        name: 'Sucursal Norte',
        address: 'Zona norte',
        isActive: false,
        createdAt: DateTime.utc(2026, 6, 1),
        updatedAt: DateTime.utc(2026, 6, 5),
      );

      expect(branch.address, 'Zona norte');
      expect(branch.isActive, isFalse);
      expect(branch.updatedAt, DateTime.utc(2026, 6, 5));
    });
  });
}
