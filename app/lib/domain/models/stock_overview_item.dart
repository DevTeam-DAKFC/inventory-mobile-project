/// Read model used by the stock overview screen.
///
/// The backend returns stock together with lightweight product and branch data,
/// so this model keeps the UI-facing fields together without changing the base
/// Stock entity that is keyed by productId + branchId.
final class StockOverviewItem {
  const StockOverviewItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.branchId,
    required this.branchName,
    required this.availableQuantity,
    required this.minStock,
    required this.isLowStock,
    this.sku,
    this.productImageUrl,
    this.branchAddress,
    this.lastMovementAt,
    this.updatedAt,
  });

  final String id;
  final String productId;
  final String productName;
  final String? sku;
  final String? productImageUrl;
  final String branchId;
  final String branchName;
  final String? branchAddress;
  final int availableQuantity;
  final int minStock;
  final bool isLowStock;
  final DateTime? lastMovementAt;
  final DateTime? updatedAt;

  bool get isOutOfStock => availableQuantity == 0;
}
