import '../../domain/models/branch.dart';
import '../../domain/models/product.dart';
import '../../domain/models/stock_lookup.dart';

abstract class MovementReferenceResolver {
  String productLabel(String productId, {StockLookup? stockLookup});

  String branchLabel(String branchId, {StockLookup? stockLookup});

  String userLabel(String userId);
}

final class FallbackMovementReferenceResolver
    implements MovementReferenceResolver {
  const FallbackMovementReferenceResolver({
    this.products = const [],
    this.branches = const [],
  });

  final List<Product> products;
  final List<Branch> branches;

  @override
  String productLabel(String productId, {StockLookup? stockLookup}) {
    if (stockLookup?.product.id == productId) {
      return stockLookup!.product.name;
    }
    for (final product in products) {
      if (product.id == productId) return product.name;
    }
    return 'Product ${_shortId(productId)}';
  }

  @override
  String branchLabel(String branchId, {StockLookup? stockLookup}) {
    if (stockLookup?.branch.id == branchId) {
      return stockLookup!.branch.name;
    }
    for (final branch in branches) {
      if (branch.id == branchId) return branch.name;
    }
    return 'Branch ${_shortId(branchId)}';
  }

  @override
  String userLabel(String userId) => 'User ${_shortId(userId)}';

  String _shortId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'unknown';
    return trimmed.length <= 8 ? trimmed : trimmed.substring(0, 8);
  }
}
