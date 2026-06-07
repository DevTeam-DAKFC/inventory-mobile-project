import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../dto/paginated_product_rest_dto.dart';
import '../dto/product_rest_dto.dart';

final class ProductMapper {
  const ProductMapper._();

  static Product toDomain(ProductRestDto dto) {
    return Product(
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
  }

  static PaginatedResult<Product> toPaginatedDomain(
    PaginatedProductRestDto dto,
  ) {
    return PaginatedResult(
      items: dto.items.map(toDomain).toList(),
      page: dto.page,
      pageSize: dto.pageSize,
      totalCount: dto.total,
    );
  }
}
