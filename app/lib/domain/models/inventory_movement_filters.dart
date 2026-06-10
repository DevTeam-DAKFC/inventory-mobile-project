import 'inventory_movement.dart';

/// Filters accepted by the paginated inventory movement history endpoint.
final class InventoryMovementFilters {
  const InventoryMovementFilters({
    this.productId,
    this.branchId,
    this.type,
    this.userId,
    this.from,
    this.to,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? productId;
  final String? branchId;
  final MovementType? type;
  final String? userId;
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int pageSize;

  InventoryMovementFilters copyWith({
    String? productId,
    String? branchId,
    MovementType? type,
    String? userId,
    DateTime? from,
    DateTime? to,
    int? page,
    int? pageSize,
    bool clearProductId = false,
    bool clearBranchId = false,
    bool clearType = false,
    bool clearUserId = false,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    return InventoryMovementFilters(
      productId: clearProductId ? null : productId ?? this.productId,
      branchId: clearBranchId ? null : branchId ?? this.branchId,
      type: clearType ? null : type ?? this.type,
      userId: clearUserId ? null : userId ?? this.userId,
      from: clearFrom ? null : from ?? this.from,
      to: clearTo ? null : to ?? this.to,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
