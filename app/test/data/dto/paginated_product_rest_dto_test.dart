import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/paginated_product_rest_dto.dart';

void main() {
  group('PaginatedProductRestDto', () {
    test('parses paginated products response', () {
      final dto = PaginatedProductRestDto.fromJson({
        'items': [
          {
            'id': 'product-id',
            'name': 'Rice 1kg',
            'sku': 'RICE-001',
            'category': 'Food',
            'minStock': 10,
            'isActive': true,
            'createdAt': '2026-06-05T20:00:00Z',
          },
        ],
        'total': 1,
        'page': 1,
        'pageSize': 100,
        'hasNextPage': false,
      });

      expect(dto.items, hasLength(1));
      expect(dto.items.single.name, 'Rice 1kg');
      expect(dto.pageSize, 100);
      expect(dto.hasNextPage, isFalse);
    });

    test('throws AppException when items is not a list', () {
      expect(
        () => PaginatedProductRestDto.fromJson({
          'items': null,
          'total': 0,
          'page': 1,
          'pageSize': 100,
          'hasNextPage': false,
        }),
        throwsA(isA<AppException>()),
      );
    });
  });
}
