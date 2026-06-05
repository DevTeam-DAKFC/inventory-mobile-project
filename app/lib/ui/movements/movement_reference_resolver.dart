import '../../domain/models/stock_lookup.dart';

abstract class MovementReferenceResolver {
  String productLabel(String productId, {StockLookup? stockLookup});

  String branchLabel(String branchId, {StockLookup? stockLookup});

  String userLabel(String userId);
}

final class FallbackMovementReferenceResolver
    implements MovementReferenceResolver {
  const FallbackMovementReferenceResolver();

  static const Map<String, String> _knownProducts = {
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa': 'Rice 1kg',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb': 'Beans 900g',
    'cccccccc-cccc-cccc-cccc-cccccccccccc': 'Cooking Oil 1L',
  };

  static const Map<String, String> _knownBranches = {
    '11111111-1111-1111-1111-111111111111': 'Central Branch',
    '22222222-2222-2222-2222-222222222222': 'North Branch',
  };

  @override
  String productLabel(String productId, {StockLookup? stockLookup}) {
    if (stockLookup?.product.id == productId) {
      return stockLookup!.product.name;
    }
    return _knownProducts[productId] ?? 'Product ${_shortId(productId)}';
  }

  @override
  String branchLabel(String branchId, {StockLookup? stockLookup}) {
    if (stockLookup?.branch.id == branchId) {
      return stockLookup!.branch.name;
    }
    return _knownBranches[branchId] ?? 'Branch ${_shortId(branchId)}';
  }

  @override
  String userLabel(String userId) => 'User ${_shortId(userId)}';

  String _shortId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'unknown';
    return trimmed.length <= 8 ? trimmed : trimmed.substring(0, 8);
  }
}

final class MovementSelectOption {
  const MovementSelectOption({required this.id, required this.label});

  final String id;
  final String label;
}

const movementProductOptions = [
  MovementSelectOption(
    id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    label: 'Rice 1kg',
  ),
  MovementSelectOption(
    id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    label: 'Beans 900g',
  ),
  MovementSelectOption(
    id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    label: 'Cooking Oil 1L',
  ),
];

const movementBranchOptions = [
  MovementSelectOption(
    id: '11111111-1111-1111-1111-111111111111',
    label: 'Central Branch',
  ),
  MovementSelectOption(
    id: '22222222-2222-2222-2222-222222222222',
    label: 'North Branch',
  ),
];
