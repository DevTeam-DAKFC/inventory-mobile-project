import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/inventory_movement_rest_dto.dart';

void main() {
  group('InventoryMovementRestDto', () {
    test('parses valid JSON', () {
      final dto = InventoryMovementRestDto.fromJson({
        'id': 'movement-id',
        'productId': 'product-id',
        'branchId': 'branch-id',
        'userId': 'user-id',
        'type': 'incoming',
        'quantity': 5,
        'previousStock': 10,
        'resultingStock': 15,
        'reason': 'Restock',
        'notes': 'Vendor delivery',
        'createdAt': '2026-06-05T12:00:00Z',
      });

      expect(dto.id, 'movement-id');
      expect(dto.productId, 'product-id');
      expect(dto.branchId, 'branch-id');
      expect(dto.userId, 'user-id');
      expect(dto.type, 'incoming');
      expect(dto.quantity, 5);
      expect(dto.previousStock, 10);
      expect(dto.resultingStock, 15);
      expect(dto.reason, 'Restock');
      expect(dto.notes, 'Vendor delivery');
      expect(dto.createdAt, DateTime.parse('2026-06-05T12:00:00Z'));
    });

    test('serializes to JSON', () {
      final dto = InventoryMovementRestDto(
        id: 'movement-id',
        productId: 'product-id',
        branchId: 'branch-id',
        userId: 'user-id',
        type: 'outgoing',
        quantity: 2,
        previousStock: 10,
        resultingStock: 8,
        reason: 'Sale',
        createdAt: DateTime.utc(2026, 6, 5, 12),
      );

      expect(dto.toJson(), {
        'id': 'movement-id',
        'productId': 'product-id',
        'branchId': 'branch-id',
        'userId': 'user-id',
        'type': 'outgoing',
        'quantity': 2,
        'previousStock': 10,
        'resultingStock': 8,
        'reason': 'Sale',
        'createdAt': '2026-06-05T12:00:00.000Z',
      });
    });

    test('throws AppException when required fields are invalid', () {
      expect(
        () => InventoryMovementRestDto.fromJson({'id': 'movement-id'}),
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
