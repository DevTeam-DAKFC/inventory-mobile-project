import 'product.dart';

/// A page returned by the product catalog.
final class PaginatedProducts {
  const PaginatedProducts({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasNextPage,
  });

  final List<Product> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasNextPage;
}
