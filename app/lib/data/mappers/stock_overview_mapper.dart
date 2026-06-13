import '../../domain/models/stock_overview_item.dart';
import '../dto/stock_overview_rest_dto.dart';

final class StockOverviewMapper {
  const StockOverviewMapper._();

  static StockOverviewItem toDomain(StockOverviewRestDto dto) {
    return StockOverviewItem(
      id: dto.id,
      productId: dto.productId,
      productName: dto.productName,
      sku: dto.sku,
      productImageUrl: dto.productImageUrl,
      branchId: dto.branchId,
      branchName: dto.branchName,
      branchAddress: dto.branchAddress,
      availableQuantity: dto.availableQuantity,
      minStock: dto.minStock,
      isLowStock: dto.isLowStock,
      lastMovementAt: dto.lastMovementAt,
      updatedAt: dto.updatedAt,
    );
  }
}
