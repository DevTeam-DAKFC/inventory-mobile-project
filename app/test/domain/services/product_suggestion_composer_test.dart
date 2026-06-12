import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/external_product_suggestion.dart';
import 'package:inventory_mobile/domain/services/product_suggestion_composer.dart';

void main() {
  const composer = ProductSuggestionComposer();

  test('suggests SKU from normalized name and barcode suffix', () {
    final result = composer.compose(
      const ExternalProductSuggestion(
        barcode: '3017624010701',
        name: 'Ñame orgánico',
        source: 'open_food_facts',
      ),
    );

    expect(result.sku, 'NAM-010701');
  });

  test('uses a stable fallback when product name is unavailable', () {
    final result = composer.compose(
      const ExternalProductSuggestion(
        barcode: '1234',
        source: 'open_food_facts',
      ),
    );

    expect(result.sku, 'PRD-001234');
  });
}
