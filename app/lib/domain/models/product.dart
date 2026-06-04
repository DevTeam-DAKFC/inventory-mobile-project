/// Product in the catalog.
///
/// Stock balances are not embedded here. They are represented by the `Stock`
/// entity scoped by `productId` and `branchId`. `minStock` is a low-stock
/// threshold, not a current quantity.
final class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.minStock,
    required this.isActive,
    required this.createdAt,
    this.barcode,
    this.description,
    this.imageUrl,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final String category;
  final String? description;
  final String? imageUrl;
  final int minStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
