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
  final StockLookupProduct product;
  final StockLookupBranch branch;
}

final class StockLookupProduct {
  const StockLookupProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    this.barcode,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String sku;
  final String category;
  final String? barcode;
  final String? imageUrl;
}

final class StockLookupBranch {
  const StockLookupBranch({required this.id, required this.name, this.address});

  final String id;
  final String name;
  final String? address;
}
