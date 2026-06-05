/// Type of an inventory movement.
enum MovementType { incoming, outgoing, adjustment }

/// Inventory movement record.
///
/// `previousStock` and `resultingStock` capture the balance before and after
/// the movement was applied, supporting full traceability.
final class InventoryMovement {
  const InventoryMovement({
    required this.id,
    required this.productId,
    required this.branchId,
    required this.userId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.resultingStock,
    required this.reason,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String productId;
  final String branchId;
  final String userId;
  final MovementType type;
  final int quantity;
  final int previousStock;
  final int resultingStock;
  final String reason;
  final String? notes;
  final DateTime createdAt;
}
