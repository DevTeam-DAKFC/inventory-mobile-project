import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/inventory_movement_create_request_dto.dart';

void main() {
  group('InventoryMovementCreateRequestDto', () {
    test('serializes required fields', () {
      const dto = InventoryMovementCreateRequestDto(
        productId: 'product-id',
        branchId: 'branch-id',
        type: 'incoming',
        quantity: 5,
        reason: 'Restock',
      );

      expect(dto.toJson(), {
        'productId': 'product-id',
        'branchId': 'branch-id',
        'type': 'incoming',
        'quantity': 5,
        'reason': 'Restock',
      });
    });

    test('serializes non-empty optional notes', () {
      const dto = InventoryMovementCreateRequestDto(
        productId: 'product-id',
        branchId: 'branch-id',
        type: 'outgoing',
        quantity: 2,
        reason: 'Sale',
        notes: 'Customer purchase',
      );

      expect(dto.toJson()['notes'], 'Customer purchase');
    });
  });
}
