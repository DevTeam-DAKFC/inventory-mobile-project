import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';

void main() {
  group('MovementType', () {
    test('exposes incoming, outgoing and adjustment', () {
      expect(MovementType.values, [
        MovementType.incoming,
        MovementType.outgoing,
        MovementType.adjustment,
      ]);
    });
  });

  group('InventoryMovement', () {
    test('can be constructed with required fields', () {
      final createdAt = DateTime.utc(2026, 6, 2, 20, 15);
      final movement = InventoryMovement(
        id: 'movement_001',
        productId: 'product_rice_001',
        branchId: 'branch_central',
        userId: 'user_admin_001',
        type: MovementType.incoming,
        quantity: 40,
        previousStock: 0,
        resultingStock: 40,
        reason: 'Initial import',
        createdAt: createdAt,
      );

      expect(movement.id, 'movement_001');
      expect(movement.productId, 'product_rice_001');
      expect(movement.branchId, 'branch_central');
      expect(movement.userId, 'user_admin_001');
      expect(movement.type, MovementType.incoming);
      expect(movement.quantity, 40);
      expect(movement.reason, 'Initial import');
      expect(movement.notes, isNull);
      expect(movement.createdAt, createdAt);
    });

    test('preserves previousStock and resultingStock', () {
      final movement = InventoryMovement(
        id: 'movement_002',
        productId: 'product_rice_001',
        branchId: 'branch_north',
        userId: 'user_collaborator_001',
        type: MovementType.outgoing,
        quantity: 4,
        previousStock: 10,
        resultingStock: 6,
        reason: 'Sale',
        notes: 'Salida por venta registrada.',
        createdAt: DateTime.utc(2026, 6, 2, 20, 20),
      );

      expect(movement.previousStock, 10);
      expect(movement.resultingStock, 6);
      expect(movement.notes, 'Salida por venta registrada.');
    });
  });
}
