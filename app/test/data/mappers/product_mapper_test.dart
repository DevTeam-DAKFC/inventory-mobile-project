import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/paginated_products_rest_dto.dart';
import 'package:inventory_mobile/data/dto/product_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/product_mapper.dart';

void main() {
  final dto = ProductRestDto(
    id: 'product_1',
    name: 'Arroz',
    sku: 'ARR-001',
    category: 'Abarrotes',
    minStock: 10,
    isActive: true,
    createdAt: DateTime.utc(2026, 6, 2),
    imageUrl: 'https://example.com/product.jpg',
  );

  test('maps ProductRestDto to Product without stock quantities', () {
    final product = ProductMapper.toDomain(dto);

    expect(product.id, 'product_1');
    expect(product.imageUrl, 'https://example.com/product.jpg');
    expect(product.minStock, 10);
  });

  test('maps paginated DTO metadata and products', () {
    final page = ProductMapper.pageToDomain(
      PaginatedProductsRestDto(
        items: [dto],
        total: 1,
        page: 1,
        pageSize: 20,
        hasNextPage: false,
      ),
    );

    expect(page.items.single.id, 'product_1');
    expect(page.total, 1);
    expect(page.hasNextPage, isFalse);
  });
}
