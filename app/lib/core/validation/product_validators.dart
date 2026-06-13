/// Form-field validators for the product catalog.
///
/// Returns `null` when the value is valid, or a human-readable English error
/// message otherwise.
final class ProductValidators {
  const ProductValidators._();

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    return null;
  }

  static String? validateSku(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'SKU is required.';
    }
    if (value.trim().length < 2) {
      return 'SKU must be at least 2 characters long.';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category is required.';
    }
    return null;
  }

  static String? validateMinStock(num? value) {
    if (value == null) {
      return 'Minimum stock is required.';
    }
    if (value < 0) {
      return 'Minimum stock cannot be negative.';
    }
    return null;
  }

  /// Optional barcode. Returns `null` when not provided.
  static String? validateBarcode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final trimmed = value.trim();
    if (!_digitsOnly.hasMatch(trimmed)) {
      return 'Barcode must contain only digits.';
    }
    if (trimmed.length < 8 || trimmed.length > 14) {
      return 'Barcode length must be between 8 and 14 digits.';
    }
    return null;
  }
}
