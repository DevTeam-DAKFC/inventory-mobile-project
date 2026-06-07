/// Form-field and domain-rule validators for inventory movements.
///
/// Returns `null` when the value is valid, or a human-readable error message
/// otherwise.
final class MovementValidators {
  const MovementValidators._();

  static String? validateProductId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El producto es requerido.';
    }
    return null;
  }

  static String? validateBranchId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La sucursal es requerida.';
    }
    return null;
  }

  static String? validateQuantity(num? value) {
    if (value == null) {
      return 'La cantidad es requerida.';
    }
    if (value <= 0) {
      return 'La cantidad debe ser mayor que cero.';
    }
    return null;
  }

  static String? validateReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El motivo es requerido.';
    }
    if (value.trim().length < 2) {
      return 'El motivo debe tener al menos 2 caracteres.';
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
      return 'El stock disponible no puede ser negativo.';
    }
    if (requestedQuantity <= 0) {
      return 'La cantidad solicitada debe ser mayor que cero.';
    }
    if (requestedQuantity > availableQuantity) {
      return 'No hay stock suficiente para registrar esta salida.';
    }
    return null;
  }
}
