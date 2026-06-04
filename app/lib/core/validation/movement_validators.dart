/// Form-field and domain-rule validators for inventory movements.
///
/// Returns `null` when the value is valid, or a human-readable English error
/// message otherwise.
final class MovementValidators {
  const MovementValidators._();

  static String? validateProductId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product is required.';
    }
    return null;
  }

  static String? validateBranchId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Branch is required.';
    }
    return null;
  }

  static String? validateQuantity(num? value) {
    if (value == null) {
      return 'Quantity is required.';
    }
    if (value <= 0) {
      return 'Quantity must be greater than zero.';
    }
    return null;
  }

  static String? validateReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Reason is required.';
    }
    if (value.trim().length < 2) {
      return 'Reason must be at least 2 characters long.';
    }
    return null;
  }

  /// Cross-field rule applied before registering an outgoing movement.
  ///
  /// Mirrors the `insufficient_stock` 422 response described in
  /// `docs/api-contracts/openapi.inventory-api.yaml`.
  static String? validateOutgoingStock({
    required num availableQuantity,
    required num requestedQuantity,
  }) {
    if (availableQuantity < 0) {
      return 'Available stock cannot be negative.';
    }
    if (requestedQuantity <= 0) {
      return 'Requested quantity must be greater than zero.';
    }
    if (requestedQuantity > availableQuantity) {
      return 'Not enough stock available to register this movement.';
    }
    return null;
  }
}
