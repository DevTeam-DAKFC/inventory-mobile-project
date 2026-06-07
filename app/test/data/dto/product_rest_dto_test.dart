import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/product_rest_dto.dart';

void main() {
  group('ProductRestDto', () {
    test('parses product JSON with optional fields', () {
      final dto = ProductRestDto.fromJson({
        'id': 'product-id',
        'name': 'Rice 1kg',
        'sku': 'RICE-001',
        'barcode': '7441000000011',
        'category': 'Food',
        'description': 'White rice',
        'imageUrl': 'https://example.com/rice.png',
        'minStock': 10,
        'isActive': true,
        'createdAt': '2026-06-05T20:00:00Z',
        'updatedAt': '2026-06-05T21:00:00Z',
      });

      expect(dto.id, 'product-id');
      expect(dto.name, 'Rice 1kg');
      expect(dto.barcode, '7441000000011');
      expect(dto.minStock, 10);
      expect(dto.isActive, isTrue);
      expect(dto.updatedAt, DateTime.parse('2026-06-05T21:00:00Z'));
    });

    test('allows nullable optional fields', () {
      final dto = ProductRestDto.fromJson({
        'id': 'product-id',
        'name': 'Rice 1kg',
        'sku': 'RICE-001',
        'barcode': null,
        'category': 'Food',
        'description': null,
        'imageUrl': null,
        'minStock': 10,
        'isActive': true,
        'createdAt': '2026-06-05T20:00:00Z',
        'updatedAt': null,
      });

      expect(dto.barcode, isNull);
      expect(dto.description, isNull);
      expect(dto.imageUrl, isNull);
      expect(dto.updatedAt, isNull);
    });

    test('throws AppException for invalid required fields', () {
      expect(
        () => ProductRestDto.fromJson({
          'id': '',
          'name': 'Rice 1kg',
          'sku': 'RICE-001',
          'category': 'Food',
          'minStock': 10,
          'isActive': true,
          'createdAt': '2026-06-05T20:00:00Z',
        }),
        throwsA(isA<AppException>()),
      );
    });
  });
}
