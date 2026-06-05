import 'branch.dart';
import 'product.dart';

/// Stock lookup result for a product and branch pair.
///
/// This model is read-only from the mobile perspective. Stock changes are
/// created through inventory movements on the backend.
final class StockLookup {
  const StockLookup({
    required this.id,
    required this.availableQuantity,
    required this.minStock,
    required this.isLowStock,
    required this.product,
    required this.branch,
    this.lastMovementAt,
    this.updatedAt,
  });

  final String id;
  final int availableQuantity;
  final int minStock;
  final bool isLowStock;
  final DateTime? lastMovementAt;
  final DateTime? updatedAt;
  final Product product;
  final Branch branch;
}
