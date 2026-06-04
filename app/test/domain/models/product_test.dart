import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/product.dart';

void main() {
  group('Product', () {
    test('can be constructed with required fields', () {
      final createdAt = DateTime.utc(2026, 6, 2);
      final product = Product(
        id: 'product_rice_001',
        name: 'Arroz 80% 1kg',
        sku: 'ARR-001',
        category: 'Abarrotes',
        minStock: 10,
        isActive: true,
        createdAt: createdAt,
      );

      expect(product.id, 'product_rice_001');
      expect(product.name, 'Arroz 80% 1kg');
      expect(product.sku, 'ARR-001');
      expect(product.category, 'Abarrotes');
      expect(product.minStock, 10);
      expect(product.isActive, isTrue);
      expect(product.createdAt, createdAt);
      expect(product.barcode, isNull);
      expect(product.description, isNull);
      expect(product.imageUrl, isNull);
      expect(product.updatedAt, isNull);
    });

    test('preserves optional fields when provided', () {
      final product = Product(
        id: 'product_rice_001',
        name: 'Arroz 80% 1kg',
        sku: 'ARR-001',
        barcode: '7441000000012',
        category: 'Abarrotes',
        description: 'Bolsa de arroz 80% de 1 kilogramo.',
        imageUrl: 'https://example.com/images/arroz-1kg.jpg',
        minStock: 10,
        isActive: true,
        createdAt: DateTime.utc(2026, 6, 2),
        updatedAt: DateTime.utc(2026, 6, 3),
      );

      expect(product.barcode, '7441000000012');
      expect(product.description, 'Bolsa de arroz 80% de 1 kilogramo.');
      expect(product.imageUrl, 'https://example.com/images/arroz-1kg.jpg');
      expect(product.updatedAt, DateTime.utc(2026, 6, 3));
    });

    test('exposes only catalog metadata, with no embedded stock counter', () {
      final product = Product(
        id: 'p',
        name: 'name',
        sku: 'sku',
        category: 'cat',
        minStock: 0,
        isActive: true,
        createdAt: DateTime.utc(2026, 6, 2),
      );

      // Documents the rule from docs/architecture/data-model.md §6:
      // stock balances live in the Stock entity scoped by productId and
      // branchId, never on Product. `minStock` is a low-stock threshold,
      // not a current quantity.
      expect(product.minStock, 0);
      expect(product.isActive, isTrue);
    });
  });
}
