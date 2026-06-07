final class InventoryMovementCreateRequestDto {
  const InventoryMovementCreateRequestDto({
    required this.productId,
    required this.branchId,
    required this.type,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  final String productId;
  final String branchId;
  final String type;
  final int quantity;
  final String reason;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'branchId': branchId,
    'type': type,
    'quantity': quantity,
    'reason': reason,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
  };
}
