import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_filters.dart';

void main() {
  group('InventoryMovementFilters', () {
    test('uses default pagination values', () {
      const filters = InventoryMovementFilters();

      expect(filters.page, 1);
      expect(filters.pageSize, 20);
    });

    test('can store all supported backend filters', () {
      final from = DateTime.utc(2026, 6, 1);
      final to = DateTime.utc(2026, 6, 5);
      final filters = InventoryMovementFilters(
        productId: 'product-id',
        branchId: 'branch-id',
        type: MovementType.outgoing,
        userId: 'user-id',
        from: from,
        to: to,
        page: 2,
        pageSize: 10,
      );

      expect(filters.productId, 'product-id');
      expect(filters.branchId, 'branch-id');
      expect(filters.type, MovementType.outgoing);
      expect(filters.userId, 'user-id');
      expect(filters.from, from);
      expect(filters.to, to);
      expect(filters.page, 2);
      expect(filters.pageSize, 10);
    });

    test('copyWith updates and clears fields', () {
      const filters = InventoryMovementFilters(
        productId: 'product-id',
        branchId: 'branch-id',
        type: MovementType.incoming,
      );

      final updated = filters.copyWith(
        branchId: 'new-branch-id',
        clearProductId: true,
        clearType: true,
        page: 3,
      );

      expect(updated.productId, isNull);
      expect(updated.branchId, 'new-branch-id');
      expect(updated.type, isNull);
      expect(updated.page, 3);
      expect(updated.pageSize, 20);
    });
  });
}
