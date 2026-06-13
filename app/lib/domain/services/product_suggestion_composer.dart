import '../models/external_product_suggestion.dart';
import '../models/product_form_suggestion.dart';

/// Derives editable form values without adding facts not supplied by lookup.
final class ProductSuggestionComposer {
  const ProductSuggestionComposer();

  ProductFormSuggestion compose(ExternalProductSuggestion suggestion) {
    return ProductFormSuggestion(sku: _sku(suggestion.name, suggestion.barcode));
  }

  String _sku(String? name, String barcode) {
    final normalizedName = _normalize(name ?? '');
    final prefix = normalizedName.isEmpty
        ? 'PRD'
        : normalizedName.length >= 3
        ? normalizedName.substring(0, 3)
        : normalizedName.padRight(3, 'X');
    final normalizedBarcode = barcode.replaceAll(RegExp(r'[^0-9]'), '');
    final suffix = normalizedBarcode.length > 6
        ? normalizedBarcode.substring(normalizedBarcode.length - 6)
        : normalizedBarcode.padLeft(6, '0');
    return '$prefix-$suffix';
  }

  String _normalize(String value) {
    const replacements = {
      'Á': 'A',
      'À': 'A',
      'Ä': 'A',
      'Â': 'A',
      'É': 'E',
      'È': 'E',
      'Ë': 'E',
      'Ê': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Ï': 'I',
      'Î': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ö': 'O',
      'Ô': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Ü': 'U',
      'Û': 'U',
      'Ñ': 'N',
    };
    final upper = value.trim().toUpperCase();
    final buffer = StringBuffer();
    for (final rune in upper.runes) {
      final character = String.fromCharCode(rune);
      buffer.write(replacements[character] ?? character);
    }
    return buffer.toString().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }
}
