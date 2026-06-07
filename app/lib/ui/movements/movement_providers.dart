import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/app_result.dart';
import '../../data/providers/branch_providers.dart';
import '../../data/providers/inventory_movement_providers.dart';
import '../../data/providers/product_providers.dart';
import '../../domain/models/branch.dart';
import '../../domain/models/inventory_movement.dart';
import '../../domain/models/inventory_movement_filters.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_list_query.dart';
import '../../domain/models/stock_lookup.dart';
import 'movement_reference_resolver.dart';

typedef StockLookupRequest = ({String productId, String branchId});

final movementReferenceResolverProvider = Provider<MovementReferenceResolver>((
  ref,
) {
  final productResult = ref.watch(activeProductCatalogProvider).asData?.value;
  final branchResult = ref.watch(branchCatalogProvider).asData?.value;
  final products = productResult?.dataOrNull;
  final branches = branchResult?.dataOrNull;

  return FallbackMovementReferenceResolver(
    products: products ?? const [],
    branches: branches ?? const [],
  );
});

final movementHistoryProvider =
    FutureProvider.family<
      AppResult<PaginatedResult<InventoryMovement>>,
      InventoryMovementFilters
    >((ref, filters) {
      return ref
          .watch(inventoryMovementRepositoryProvider)
          .getMovements(filters);
    });

final movementDetailProvider =
    FutureProvider.family<AppResult<InventoryMovement>, String>((
      ref,
      movementId,
    ) {
      return ref
          .watch(inventoryMovementRepositoryProvider)
          .getMovementById(movementId);
    });

final stockLookupProvider =
    FutureProvider.family<AppResult<StockLookup>, StockLookupRequest>((
      ref,
      request,
    ) {
      return ref
          .watch(stockLookupRepositoryProvider)
          .getStockLookup(
            productId: request.productId,
            branchId: request.branchId,
          );
    });

final branchCatalogProvider = FutureProvider<AppResult<List<Branch>>>((ref) {
  return ref.watch(allBranchesProvider.future);
});

final activeBranchCatalogProvider = FutureProvider<AppResult<List<Branch>>>((
  ref,
) {
  return ref.watch(branchesProvider.future);
});

final activeProductCatalogProvider = FutureProvider<AppResult<List<Product>>>(
  (ref) async {
    final result = await ref
        .watch(productRepositoryProvider)
        .listProducts(
          const ProductListQuery(isActive: true, page: 1, pageSize: 100),
        );
    return result.when(
      success: (page) => AppSuccess(page.items),
      failure: AppFailure.new,
    );
  },
);

final inactiveProductCatalogProvider = FutureProvider<AppResult<List<Product>>>(
  (ref) async {
    final result = await ref
        .watch(productRepositoryProvider)
        .listProducts(
          const ProductListQuery(isActive: false, page: 1, pageSize: 100),
        );
    return result.when(
      success: (page) => AppSuccess(page.items),
      failure: AppFailure.new,
    );
  },
);
