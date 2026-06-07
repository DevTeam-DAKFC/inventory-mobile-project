import '../../core/result/app_result.dart';
import '../models/inventory_movement.dart';
import '../models/inventory_movement_create_request.dart';
import '../models/inventory_movement_filters.dart';
import '../models/paginated_result.dart';

abstract class InventoryMovementRepository {
  Future<AppResult<InventoryMovement>> createMovement(
    InventoryMovementCreateRequest request,
  );

  Future<AppResult<PaginatedResult<InventoryMovement>>> getMovements(
    InventoryMovementFilters filters,
  );

  Future<AppResult<InventoryMovement>> getMovementById(String movementId);
}
