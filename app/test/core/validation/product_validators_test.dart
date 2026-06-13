import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/validation/product_validators.dart';

void main() {
  group('ProductValidators field validators', () {
    test('valid product fields return null', () {
      expect(ProductValidators.validateName('Arroz 80% 1kg'), isNull);
      expect(ProductValidators.validateSku('ARR-001'), isNull);
      expect(ProductValidators.validateCategory('Abarrotes'), isNull);
      expect(ProductValidators.validateMinStock(10), isNull);
      expect(ProductValidators.validateBarcode('7441000000012'), isNull);
    });

    test('empty name returns error', () {
      expect(ProductValidators.validateName(null), isNotNull);
      expect(ProductValidators.validateName(''), isNotNull);
      expect(ProductValidators.validateName('   '), isNotNull);
    });

    test('empty SKU returns error', () {
      expect(ProductValidators.validateSku(null), isNotNull);
      expect(ProductValidators.validateSku(''), isNotNull);
      expect(ProductValidators.validateSku('   '), isNotNull);
    });

    test('empty category returns error', () {
      expect(ProductValidators.validateCategory(null), isNotNull);
      expect(ProductValidators.validateCategory(''), isNotNull);
      expect(ProductValidators.validateCategory('   '), isNotNull);
    });

    test('minStock 0 is valid', () {
      expect(ProductValidators.validateMinStock(0), isNull);
    });

    test('positive minStock is valid', () {
      expect(ProductValidators.validateMinStock(5), isNull);
      expect(ProductValidators.validateMinStock(100), isNull);
    });

    test('negative minStock returns error', () {
      expect(ProductValidators.validateMinStock(-1), isNotNull);
      expect(ProductValidators.validateMinStock(-100), isNotNull);
    });

    test('empty barcode is valid', () {
      expect(ProductValidators.validateBarcode(null), isNull);
      expect(ProductValidators.validateBarcode(''), isNull);
      expect(ProductValidators.validateBarcode('   '), isNull);
    });

    test('numeric barcode length 8 to 14 is valid', () {
      expect(ProductValidators.validateBarcode('12345678'), isNull); // 8
      expect(ProductValidators.validateBarcode('7441000000012'), isNull); // 13
      expect(ProductValidators.validateBarcode('12345678901234'), isNull); // 14
    });

    test('non-numeric barcode returns error', () {
      expect(ProductValidators.validateBarcode('ABCD1234'), isNotNull);
      expect(ProductValidators.validateBarcode('123-456-78'), isNotNull);
      expect(ProductValidators.validateBarcode('12345 678'), isNotNull);
    });

    test('too-short barcode returns error', () {
      expect(ProductValidators.validateBarcode('1234567'), isNotNull); // 7
      expect(ProductValidators.validateBarcode('1'), isNotNull);
    });

    test('too-long barcode returns error', () {
      expect(
        ProductValidators.validateBarcode('123456789012345'),
        isNotNull,
      ); // 15
    });
  });
}
