import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/branch_repository.dart';
import '../../domain/repositories/inventory_movement_repository.dart';
import '../../domain/repositories/stock_lookup_repository.dart';
import '../datasources/rest/rest_api_branch_data_source.dart';
import '../datasources/rest/rest_api_inventory_movement_data_source.dart';
import '../datasources/rest/rest_api_stock_lookup_data_source.dart';
import '../repositories/branch_repository_impl.dart';
import '../repositories/inventory_movement_repository_impl.dart';
import '../repositories/stock_lookup_repository_impl.dart';
import 'health_providers.dart';

final inventoryMovementDataSourceProvider =
    Provider<RestApiInventoryMovementDataSource>(
      (ref) =>
          RestApiInventoryMovementDataSource(ref.watch(apiClientProvider).dio),
    );

final inventoryMovementRepositoryProvider =
    Provider<InventoryMovementRepository>(
      (ref) => InventoryMovementRepositoryImpl(
        ref.watch(inventoryMovementDataSourceProvider),
      ),
    );

final stockLookupDataSourceProvider = Provider<RestApiStockLookupDataSource>(
  (ref) => RestApiStockLookupDataSource(ref.watch(apiClientProvider).dio),
);

final stockLookupRepositoryProvider = Provider<StockLookupRepository>(
  (ref) => StockLookupRepositoryImpl(ref.watch(stockLookupDataSourceProvider)),
);

final branchDataSourceProvider = Provider<RestApiBranchDataSource>(
  (ref) => RestApiBranchDataSource(ref.watch(apiClientProvider).dio),
);

final branchRepositoryProvider = Provider<BranchRepository>(
  (ref) => BranchRepositoryImpl(ref.watch(branchDataSourceProvider)),
);
