import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/stock_lookup.dart';

void main() {
  group('StockLookup', () {
    test('can be constructed with product and branch details', () {
      final updatedAt = DateTime.utc(2026, 6, 5);
      final stock = StockLookup(
        id: 'stock-id',
        availableQuantity: 12,
        minStock: 10,
        isLowStock: false,
        lastMovementAt: updatedAt,
        updatedAt: updatedAt,
        product: const StockLookupProduct(
          id: 'product-id',
          name: 'Rice 1kg',
          sku: 'RICE-001',
          category: 'Food',
        ),
        branch: const StockLookupBranch(
          id: 'branch-id',
          name: 'Central Branch',
        ),
      );

      expect(stock.id, 'stock-id');
      expect(stock.availableQuantity, 12);
      expect(stock.minStock, 10);
      expect(stock.isLowStock, isFalse);
      expect(stock.product.name, 'Rice 1kg');
      expect(stock.branch.name, 'Central Branch');
      expect(stock.lastMovementAt, updatedAt);
      expect(stock.updatedAt, updatedAt);
    });
  });
}
