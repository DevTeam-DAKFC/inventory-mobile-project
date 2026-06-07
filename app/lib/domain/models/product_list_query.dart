/// Filters and pagination accepted by `GET /products`.
final class ProductListQuery {
  const ProductListQuery({
    this.q,
    this.category,
    this.isActive,
    this.lowStockOnly,
    this.page,
    this.pageSize,
  });

  final String? q;
  final String? category;
  final bool? isActive;
  final bool? lowStockOnly;
  final int? page;
  final int? pageSize;
}
