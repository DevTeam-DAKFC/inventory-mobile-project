import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/stock_lookup.dart';
import 'package:inventory_mobile/ui/movements/movement_reference_resolver.dart';

void main() {
  group('FallbackMovementReferenceResolver', () {
    const resolver = FallbackMovementReferenceResolver();
    const stockLookup = StockLookup(
      id: 'stock-id',
      availableQuantity: 12,
      minStock: 10,
      isLowStock: false,
      product: StockLookupProduct(
        id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        name: 'Rice 1kg',
        sku: 'RICE-001',
        category: 'Food',
      ),
      branch: StockLookupBranch(
        id: '11111111-1111-1111-1111-111111111111',
        name: 'Central Branch',
      ),
    );

    test('uses stock lookup product name when product id matches', () {
      expect(
        resolver.productLabel(
          'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
          stockLookup: stockLookup,
        ),
        'Rice 1kg',
      );
    });

    test('uses known product labels before falling back to short ids', () {
      expect(
        resolver.productLabel('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
        'Beans 900g',
      );
      expect(resolver.productLabel('product-unknown-id'), 'Product product-');
    });

    test('uses stock lookup branch name when branch id matches', () {
      expect(
        resolver.branchLabel(
          '11111111-1111-1111-1111-111111111111',
          stockLookup: stockLookup,
        ),
        'Central Branch',
      );
    });

    test('uses known branch labels before falling back to short ids', () {
      expect(
        resolver.branchLabel('22222222-2222-2222-2222-222222222222'),
        'North Branch',
      );
      expect(resolver.branchLabel('branch-unknown-id'), 'Branch branch-u');
    });

    test('falls back to shortened user id', () {
      expect(resolver.userLabel('user-1234567890'), 'User user-123');
    });

    test('uses unknown label for empty ids', () {
      expect(resolver.productLabel('  '), 'Product unknown');
      expect(resolver.branchLabel('  '), 'Branch unknown');
      expect(resolver.userLabel('  '), 'User unknown');
    });
  });
}
