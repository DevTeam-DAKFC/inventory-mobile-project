import '../../domain/models/stock_lookup.dart';
import '../dto/stock_lookup_rest_dto.dart';

final class StockLookupMapper {
  const StockLookupMapper._();

  static StockLookup toDomain(StockLookupRestDto dto) {
    return StockLookup(
      id: dto.id,
      availableQuantity: dto.availableQuantity,
      minStock: dto.minStock,
      isLowStock: dto.isLowStock,
      lastMovementAt: dto.lastMovementAt,
      updatedAt: dto.updatedAt,
      product: StockLookupProduct(
        id: dto.product.id,
        name: dto.product.name,
        sku: dto.product.sku,
        category: dto.product.category,
        barcode: dto.product.barcode,
        imageUrl: dto.product.imageUrl,
      ),
      branch: StockLookupBranch(
        id: dto.branch.id,
        name: dto.branch.name,
        address: dto.branch.address,
      ),
    );
  }
}
