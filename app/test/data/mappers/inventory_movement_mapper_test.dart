import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/inventory_movement_rest_dto.dart';
import 'package:inventory_mobile/data/dto/paginated_inventory_movement_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/inventory_movement_mapper.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_create_request.dart';

void main() {
  group('InventoryMovementMapper', () {
    test('maps movement DTO to domain model', () {
      final dto = InventoryMovementRestDto(
        id: 'movement-id',
        productId: 'product-id',
        branchId: 'branch-id',
        userId: 'user-id',
        type: 'incoming',
        quantity: 5,
        previousStock: 10,
        resultingStock: 15,
        reason: 'Restock',
        createdAt: DateTime.utc(2026, 6, 5, 12),
      );

      final domain = InventoryMovementMapper.toDomain(dto);

      expect(domain.id, 'movement-id');
      expect(domain.type, MovementType.incoming);
      expect(domain.resultingStock, 15);
    });

    test('maps paginated movement DTO to domain model', () {
      final dto = PaginatedInventoryMovementRestDto(
        items: [
          InventoryMovementRestDto(
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
          ),
        ],
        total: 1,
        page: 1,
        pageSize: 20,
        hasNextPage: false,
      );

      final domain = InventoryMovementMapper.toPaginatedDomain(dto);

      expect(domain.items, hasLength(1));
      expect(domain.items.single.type, MovementType.outgoing);
      expect(domain.totalCount, 1);
    });

    test('maps domain create request to DTO', () {
      const request = InventoryMovementCreateRequest(
        productId: 'product-id',
        branchId: 'branch-id',
        type: MovementType.incoming,
        quantity: 5,
        reason: 'Restock',
        notes: 'Vendor delivery',
      );

      final dto = InventoryMovementMapper.toCreateRequestDto(request);

      expect(dto.toJson(), {
        'productId': 'product-id',
        'branchId': 'branch-id',
        'type': 'incoming',
        'quantity': 5,
        'reason': 'Restock',
        'notes': 'Vendor delivery',
      });
    });

    test('throws AppException for unknown movement type', () {
      final dto = InventoryMovementRestDto(
        id: 'movement-id',
        productId: 'product-id',
        branchId: 'branch-id',
        userId: 'user-id',
        type: 'unknown',
        quantity: 5,
        previousStock: 10,
        resultingStock: 15,
        reason: 'Restock',
        createdAt: DateTime.utc(2026, 6, 5, 12),
      );

      expect(
        () => InventoryMovementMapper.toDomain(dto),
        throwsA(isA<AppException>()),
      );
    });
  });
}
