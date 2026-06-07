import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/paginated_product_rest_dto.dart';
import 'package:inventory_mobile/data/dto/product_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/product_mapper.dart';

void main() {
  group('ProductMapper', () {
    test('maps product DTO to domain model', () {
      final dto = ProductRestDto(
        id: 'product-id',
        name: 'Rice 1kg',
        sku: 'RICE-001',
        barcode: '7441000000011',
        category: 'Food',
        description: 'White rice',
        imageUrl: 'https://example.com/rice.png',
        minStock: 10,
        isActive: true,
        createdAt: DateTime.utc(2026, 6, 5, 20),
        updatedAt: DateTime.utc(2026, 6, 5, 21),
      );

      final domain = ProductMapper.toDomain(dto);

      expect(domain.id, 'product-id');
      expect(domain.name, 'Rice 1kg');
      expect(domain.sku, 'RICE-001');
      expect(domain.barcode, '7441000000011');
      expect(domain.minStock, 10);
      expect(domain.isActive, isTrue);
    });

    test('maps paginated products DTO to domain result', () {
      final dto = PaginatedProductRestDto(
        items: [
          ProductRestDto(
            id: 'product-id',
            name: 'Rice 1kg',
            sku: 'RICE-001',
            category: 'Food',
            minStock: 10,
            isActive: true,
            createdAt: DateTime.utc(2026, 6, 5, 20),
          ),
        ],
        total: 1,
        page: 1,
        pageSize: 100,
        hasNextPage: false,
      );

      final domain = ProductMapper.toPaginatedDomain(dto);

      expect(domain.items, hasLength(1));
      expect(domain.items.single.name, 'Rice 1kg');
      expect(domain.totalCount, 1);
    });
  });
}
