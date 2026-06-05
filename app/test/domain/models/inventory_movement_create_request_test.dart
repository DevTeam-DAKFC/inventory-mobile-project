import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_create_request.dart';

void main() {
  group('InventoryMovementCreateRequest', () {
    test('can be constructed with required fields', () {
      const request = InventoryMovementCreateRequest(
        productId: 'product-id',
        branchId: 'branch-id',
        type: MovementType.incoming,
        quantity: 5,
        reason: 'Restock',
      );

      expect(request.productId, 'product-id');
      expect(request.branchId, 'branch-id');
      expect(request.type, MovementType.incoming);
      expect(request.quantity, 5);
      expect(request.reason, 'Restock');
      expect(request.notes, isNull);
    });

    test('preserves optional notes', () {
      const request = InventoryMovementCreateRequest(
        productId: 'product-id',
        branchId: 'branch-id',
        type: MovementType.outgoing,
        quantity: 2,
        reason: 'Sale',
        notes: 'Customer purchase',
      );

      expect(request.notes, 'Customer purchase');
    });
  });
}
