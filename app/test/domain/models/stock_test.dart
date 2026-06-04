import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/stock.dart';

void main() {
  group('Stock', () {
    test('can be constructed with required fields', () {
      const stock = Stock(
        id: 'product_rice_001_branch_central',
        productId: 'product_rice_001',
        branchId: 'branch_central',
        availableQuantity: 40,
        minStock: 10,
      );

      expect(stock.id, 'product_rice_001_branch_central');
      expect(stock.productId, 'product_rice_001');
      expect(stock.branchId, 'branch_central');
      expect(stock.availableQuantity, 40);
      expect(stock.minStock, 10);
      expect(stock.lastMovementId, isNull);
      expect(stock.lastMovementAt, isNull);
      expect(stock.updatedAt, isNull);
    });

    test('preserves optional movement metadata', () {
      final stock = Stock(
        id: 's',
        productId: 'p',
        branchId: 'b',
        availableQuantity: 5,
        minStock: 10,
        lastMovementId: 'movement_001',
        lastMovementAt: DateTime.utc(2026, 6, 2, 20, 15),
        updatedAt: DateTime.utc(2026, 6, 2, 20, 15),
      );

      expect(stock.lastMovementId, 'movement_001');
      expect(stock.lastMovementAt, DateTime.utc(2026, 6, 2, 20, 15));
      expect(stock.updatedAt, DateTime.utc(2026, 6, 2, 20, 15));
    });

    test('isLowStock returns true when availableQuantity <= minStock', () {
      const equal = Stock(
        id: 's',
        productId: 'p',
        branchId: 'b',
        availableQuantity: 10,
        minStock: 10,
      );
      const below = Stock(
        id: 's',
        productId: 'p',
        branchId: 'b',
        availableQuantity: 4,
        minStock: 10,
      );

      expect(equal.isLowStock, isTrue);
      expect(below.isLowStock, isTrue);
    });

    test('isLowStock returns false when availableQuantity > minStock', () {
      const stock = Stock(
        id: 's',
        productId: 'p',
        branchId: 'b',
        availableQuantity: 11,
        minStock: 10,
      );

      expect(stock.isLowStock, isFalse);
    });
  });
}
