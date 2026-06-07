import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/product_requests.dart';
import 'package:inventory_mobile/domain/models/product_mutations.dart';

void main() {
  group('ProductCreateRequest', () {
    test('serializes required and provided optional fields', () {
      final json = ProductCreateRequest.fromInput(
        const CreateProductInput(
          name: 'Arroz',
          sku: 'ARR-001',
          category: 'Abarrotes',
          minStock: 10,
          barcode: '7441000000012',
          imageUrl: 'https://example.com/product.jpg',
          isActive: false,
        ),
      ).toJson();

      expect(json['name'], 'Arroz');
      expect(json['barcode'], '7441000000012');
      expect(json['imageUrl'], 'https://example.com/product.jpg');
      expect(json['isActive'], isFalse);
    });

    test('omits optional fields without values', () {
      final json = ProductCreateRequest.fromInput(
        const CreateProductInput(
          name: 'Arroz',
          sku: 'ARR-001',
          category: 'Abarrotes',
          minStock: 10,
          barcode: '',
          description: ' ',
          imageUrl: '',
        ),
      ).toJson();

      expect(
        json.keys,
        containsAll(<String>['name', 'sku', 'category', 'minStock']),
      );
      expect(json, isNot(contains('barcode')));
      expect(json, isNot(contains('description')));
      expect(json, isNot(contains('imageUrl')));
      expect(json, isNot(contains('isActive')));
    });
  });

  group('ProductUpdateRequest', () {
    test('serializes only one present field', () {
      final json = ProductUpdateRequest(
        const UpdateProductInput(name: PatchField.value('Nuevo nombre')),
      ).toJson();

      expect(json, <String, dynamic>{'name': 'Nuevo nombre'});
    });

    test('serializes multiple present fields including imageUrl', () {
      final json = ProductUpdateRequest(
        const UpdateProductInput(
          sku: PatchField.value('NEW-001'),
          imageUrl: PatchField.value('https://example.com/new.jpg'),
          minStock: PatchField.value(5),
        ),
      ).toJson();

      expect(json, <String, dynamic>{
        'sku': 'NEW-001',
        'imageUrl': 'https://example.com/new.jpg',
        'minStock': 5,
      });
    });

    test('omits absent fields and serializes cleared optionals as null', () {
      final json = ProductUpdateRequest(
        const UpdateProductInput(
          barcode: PatchField.value(null),
          description: PatchField.value(null),
          imageUrl: PatchField.value(null),
        ),
      ).toJson();

      expect(json, <String, dynamic>{
        'barcode': null,
        'description': null,
        'imageUrl': null,
      });
      expect(json, isNot(contains('name')));
    });

    test('never serializes forbidden PATCH fields', () {
      final json = ProductUpdateRequest(
        const UpdateProductInput(name: PatchField.value('Arroz')),
      ).toJson();

      expect(json, isNot(contains('id')));
      expect(json, isNot(contains('createdAt')));
      expect(json, isNot(contains('updatedAt')));
      expect(json, isNot(contains('isActive')));
      expect(json, isNot(contains('stock')));
      expect(json, isNot(contains('quantity')));
    });
  });
}
