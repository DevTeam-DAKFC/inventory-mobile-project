/// Available quantity of a product in a specific branch.
///
/// A single Stock record exists per `productId` + `branchId` combination.
/// Stock balances change only through inventory movements.
final class Stock {
  const Stock({
    required this.id,
    required this.productId,
    required this.branchId,
    required this.availableQuantity,
    required this.minStock,
    this.lastMovementId,
    this.lastMovementAt,
    this.updatedAt,
  });

  final String id;
  final String productId;
  final String branchId;
  final int availableQuantity;
  final int minStock;
  final String? lastMovementId;
  final DateTime? lastMovementAt;
  final DateTime? updatedAt;

  /// True when `availableQuantity` is at or below the configured low-stock
  /// threshold.
  bool get isLowStock => availableQuantity <= minStock;
}
