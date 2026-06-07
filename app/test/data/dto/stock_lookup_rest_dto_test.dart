import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/stock_lookup_rest_dto.dart';

void main() {
  group('StockLookupRestDto', () {
    test('parses stock lookup JSON with nested product and branch', () {
      final dto = StockLookupRestDto.fromJson({
        'id': 'stock-id',
        'availableQuantity': 12,
        'minStock': 10,
        'isLowStock': false,
        'lastMovementAt': '2026-06-05T12:00:00Z',
        'updatedAt': '2026-06-05T12:01:00Z',
        'product': {
          'id': 'product-id',
          'name': 'Rice 1kg',
          'sku': 'RICE-001',
          'barcode': '7441000000012',
          'category': 'Food',
          'imageUrl': 'https://example.com/rice.png',
        },
        'branch': {
          'id': 'branch-id',
          'name': 'Central Branch',
          'address': 'San Jose',
        },
      });

      expect(dto.id, 'stock-id');
      expect(dto.availableQuantity, 12);
      expect(dto.minStock, 10);
      expect(dto.isLowStock, isFalse);
      expect(dto.product.name, 'Rice 1kg');
      expect(dto.branch.name, 'Central Branch');
      expect(dto.lastMovementAt, DateTime.parse('2026-06-05T12:00:00Z'));
      expect(dto.updatedAt, DateTime.parse('2026-06-05T12:01:00Z'));
    });

    test('throws AppException when nested product is missing', () {
      expect(
        () => StockLookupRestDto.fromJson({
          'id': 'stock-id',
          'availableQuantity': 12,
          'minStock': 10,
          'isLowStock': false,
          'branch': {'id': 'branch-id', 'name': 'Central Branch'},
        }),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });
  });
}
