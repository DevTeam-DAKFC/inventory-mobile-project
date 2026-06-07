import '../../domain/models/paginated_products.dart';
import '../../domain/models/product.dart';
import '../dto/paginated_products_rest_dto.dart';
import '../dto/product_rest_dto.dart';

/// Translates Product REST DTOs into domain models.
final class ProductMapper {
  const ProductMapper._();

  static Product toDomain(ProductRestDto dto) => Product(
    id: dto.id,
    name: dto.name,
    sku: dto.sku,
    barcode: dto.barcode,
    category: dto.category,
    description: dto.description,
    imageUrl: dto.imageUrl,
    minStock: dto.minStock,
    isActive: dto.isActive,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );

  static PaginatedProducts pageToDomain(PaginatedProductsRestDto dto) {
    return PaginatedProducts(
      items: dto.items.map(toDomain).toList(growable: false),
      total: dto.total,
      page: dto.page,
      pageSize: dto.pageSize,
      hasNextPage: dto.hasNextPage,
    );
  }
}
