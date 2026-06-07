import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/product_rest_dto.dart';

void main() {
  group('ProductRestDto', () {
    test('parses complete Product JSON', () {
      final dto = ProductRestDto.fromJson(_productJson());

      expect(dto.id, 'product_1');
      expect(dto.barcode, '7441000000012');
      expect(dto.imageUrl, 'https://example.com/product.jpg');
      expect(dto.createdAt, DateTime.parse('2026-06-02T20:00:00Z'));
      expect(dto.updatedAt, DateTime.parse('2026-06-03T20:00:00Z'));
    });

    test('parses optional fields and updatedAt as null', () {
      final dto = ProductRestDto.fromJson(
        _productJson()
          ..['barcode'] = null
          ..['description'] = null
          ..['imageUrl'] = null
          ..['updatedAt'] = null,
      );

      expect(dto.barcode, isNull);
      expect(dto.description, isNull);
      expect(dto.imageUrl, isNull);
      expect(dto.updatedAt, isNull);
    });

    test('throws controlled error for missing required field', () {
      expect(
        () => ProductRestDto.fromJson(_productJson()..remove('name')),
        throwsA(_unexpectedException),
      );
    });

    test('throws controlled error for invalid date', () {
      expect(
        () => ProductRestDto.fromJson(
          _productJson()..['createdAt'] = 'not-a-date',
        ),
        throwsA(_unexpectedException),
      );
    });

    test('normalizes offset date-times to UTC', () {
      final dto = ProductRestDto.fromJson(
        _productJson()..['createdAt'] = '2026-06-02T14:00:00-06:00',
      );

      expect(dto.createdAt, DateTime.parse('2026-06-02T20:00:00Z'));
      expect(dto.createdAt.isUtc, isTrue);
    });

    test('rejects date-time without timezone', () {
      expect(
        () => ProductRestDto.fromJson(
          _productJson()..['createdAt'] = '2026-06-02T20:00:00',
        ),
        throwsA(_unexpectedException),
      );
    });

    test('throws controlled error for unexpected field type', () {
      expect(
        () => ProductRestDto.fromJson(_productJson()..['minStock'] = '10'),
        throwsA(_unexpectedException),
      );
    });
  });
}

final _unexpectedException = isA<AppException>().having(
  (error) => error.code,
  'code',
  AppErrorCode.unexpected,
);

Map<String, dynamic> _productJson() => <String, dynamic>{
  'id': 'product_1',
  'name': 'Arroz',
  'sku': 'ARR-001',
  'barcode': '7441000000012',
  'category': 'Abarrotes',
  'description': 'Bolsa de arroz.',
  'imageUrl': 'https://example.com/product.jpg',
  'minStock': 10,
  'isActive': true,
  'createdAt': '2026-06-02T20:00:00Z',
  'updatedAt': '2026-06-03T20:00:00Z',
};
