import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/paginated_products_rest_dto.dart';

void main() {
  group('PaginatedProductsRestDto', () {
    test('parses items and pagination metadata', () {
      final dto = PaginatedProductsRestDto.fromJson(_pageJson());

      expect(dto.items, hasLength(1));
      expect(dto.items.single.id, 'product_1');
      expect(dto.total, 21);
      expect(dto.page, 1);
      expect(dto.pageSize, 20);
      expect(dto.hasNextPage, isTrue);
    });

    test('parses an empty item list', () {
      final dto = PaginatedProductsRestDto.fromJson(
        _pageJson()..['items'] = [],
      );

      expect(dto.items, isEmpty);
    });

    test('throws controlled error for invalid response', () {
      expect(
        () => PaginatedProductsRestDto.fromJson(_pageJson()..remove('total')),
        throwsA(isA<AppException>()),
      );
    });

    test('throws controlled error for invalid pagination limits', () {
      expect(
        () => PaginatedProductsRestDto.fromJson(_pageJson()..['total'] = -1),
        throwsA(isA<AppException>()),
      );
      expect(
        () => PaginatedProductsRestDto.fromJson(_pageJson()..['page'] = 0),
        throwsA(isA<AppException>()),
      );
      expect(
        () => PaginatedProductsRestDto.fromJson(_pageJson()..['pageSize'] = 0),
        throwsA(isA<AppException>()),
      );
    });
  });
}

Map<String, dynamic> _pageJson() => <String, dynamic>{
  'items': [
    <String, dynamic>{
      'id': 'product_1',
      'name': 'Arroz',
      'sku': 'ARR-001',
      'barcode': null,
      'category': 'Abarrotes',
      'description': null,
      'imageUrl': null,
      'minStock': 10,
      'isActive': true,
      'createdAt': '2026-06-02T20:00:00Z',
      'updatedAt': null,
    },
  ],
  'total': 21,
  'page': 1,
  'pageSize': 20,
  'hasNextPage': true,
};
