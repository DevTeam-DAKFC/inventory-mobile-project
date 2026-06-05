import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/app_result.dart';
import '../../data/providers/inventory_movement_providers.dart';
import '../../domain/models/inventory_movement.dart';
import '../../domain/models/inventory_movement_filters.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/stock_lookup.dart';
import 'movement_reference_resolver.dart';

typedef StockLookupRequest = ({String productId, String branchId});

final movementReferenceResolverProvider = Provider<MovementReferenceResolver>(
  (ref) => const FallbackMovementReferenceResolver(),
);

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
