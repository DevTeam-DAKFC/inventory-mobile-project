import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/external_product_suggestion.dart';

void main() {
  group('ExternalProductSuggestion', () {
    test('can be constructed without optional fields', () {
      const suggestion = ExternalProductSuggestion(
        barcode: '0000000000000',
        source: 'open_food_facts',
      );

      expect(suggestion.barcode, '0000000000000');
      expect(suggestion.source, 'open_food_facts');
      expect(suggestion.name, isNull);
      expect(suggestion.brand, isNull);
      expect(suggestion.category, isNull);
      expect(suggestion.imageUrl, isNull);
    });

    test('preserves optional fields when provided', () {
      const imageUrl = 'https://images.openfoodfacts.org/products/nutella.jpg';
      const suggestion = ExternalProductSuggestion(
        barcode: '3017624010701',
        name: 'Nutella',
        brand: 'Ferrero',
        category: 'Spreads',
        imageUrl: imageUrl,
        source: 'open_food_facts',
      );

      expect(suggestion.name, 'Nutella');
      expect(suggestion.brand, 'Ferrero');
      expect(suggestion.category, 'Spreads');
      expect(suggestion.imageUrl, imageUrl);
    });
  });
}
