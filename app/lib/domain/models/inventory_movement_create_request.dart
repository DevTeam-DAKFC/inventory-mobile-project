import 'inventory_movement.dart';

/// Domain request used to register an inventory movement.
///
/// Stock is updated by the backend when this request is submitted. Mobile code
/// must not derive or write stock balances directly from this object.
final class InventoryMovementCreateRequest {
  const InventoryMovementCreateRequest({
    required this.productId,
    required this.branchId,
    required this.type,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  final String productId;
  final String branchId;
  final MovementType type;
  final int quantity;
  final String reason;
  final String? notes;
}
