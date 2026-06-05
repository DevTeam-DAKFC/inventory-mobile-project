import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/paginated_inventory_movement_rest_dto.dart';

void main() {
  group('PaginatedInventoryMovementRestDto', () {
    test('parses a valid paginated response', () {
      final dto = PaginatedInventoryMovementRestDto.fromJson({
        'items': [
          {
            'id': 'movement-id',
            'productId': 'product-id',
            'branchId': 'branch-id',
            'userId': 'user-id',
            'type': 'incoming',
            'quantity': 5,
            'previousStock': 10,
            'resultingStock': 15,
            'reason': 'Restock',
            'createdAt': '2026-06-05T12:00:00Z',
          },
        ],
        'total': 1,
        'page': 1,
        'pageSize': 20,
        'hasNextPage': false,
      });

      expect(dto.items, hasLength(1));
      expect(dto.total, 1);
      expect(dto.page, 1);
      expect(dto.pageSize, 20);
      expect(dto.hasNextPage, isFalse);
    });
  });
}
