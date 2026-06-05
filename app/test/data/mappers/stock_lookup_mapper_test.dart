import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/stock_lookup_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/stock_lookup_mapper.dart';

void main() {
  group('StockLookupMapper', () {
    test('maps stock lookup DTO to domain model', () {
      final dto = StockLookupRestDto(
        id: 'stock-id',
        availableQuantity: 12,
        minStock: 10,
        isLowStock: false,
        lastMovementAt: DateTime.utc(2026, 6, 5, 12),
        updatedAt: DateTime.utc(2026, 6, 5, 12, 1),
        product: const StockLookupProductRestDto(
          id: 'product-id',
          name: 'Rice 1kg',
          sku: 'RICE-001',
          category: 'Food',
          barcode: '7441000000012',
          imageUrl: 'https://example.com/rice.png',
        ),
        branch: const StockLookupBranchRestDto(
          id: 'branch-id',
          name: 'Central Branch',
          address: 'San Jose',
        ),
      );

      final domain = StockLookupMapper.toDomain(dto);

      expect(domain.id, 'stock-id');
      expect(domain.availableQuantity, 12);
      expect(domain.isLowStock, isFalse);
      expect(domain.product.name, 'Rice 1kg');
      expect(domain.product.sku, 'RICE-001');
      expect(domain.branch.name, 'Central Branch');
      expect(domain.branch.address, 'San Jose');
    });
  });
}
