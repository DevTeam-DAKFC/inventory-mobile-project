import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/models/inventory_movement.dart';
import '../../domain/models/inventory_movement_create_request.dart';
import '../../domain/models/paginated_result.dart';
import '../dto/inventory_movement_create_request_dto.dart';
import '../dto/inventory_movement_rest_dto.dart';
import '../dto/paginated_inventory_movement_rest_dto.dart';

final class InventoryMovementMapper {
  const InventoryMovementMapper._();

  static InventoryMovement toDomain(InventoryMovementRestDto dto) {
    return InventoryMovement(
      id: dto.id,
      productId: dto.productId,
      branchId: dto.branchId,
      userId: dto.userId,
      type: _movementTypeFromWire(dto.type),
      quantity: dto.quantity,
      previousStock: dto.previousStock,
      resultingStock: dto.resultingStock,
      reason: dto.reason,
      notes: dto.notes,
      createdAt: dto.createdAt,
    );
  }

  static PaginatedResult<InventoryMovement> toPaginatedDomain(
    PaginatedInventoryMovementRestDto dto,
  ) {
    return PaginatedResult(
      items: dto.items.map(toDomain).toList(),
      page: dto.page,
      pageSize: dto.pageSize,
      totalCount: dto.total,
    );
  }

  static InventoryMovementCreateRequestDto toCreateRequestDto(
    InventoryMovementCreateRequest request,
  ) {
    return InventoryMovementCreateRequestDto(
      productId: request.productId,
      branchId: request.branchId,
      type: movementTypeToWire(request.type),
      quantity: request.quantity,
      reason: request.reason,
      notes: request.notes,
    );
  }

  static String movementTypeToWire(MovementType type) => switch (type) {
    MovementType.incoming => 'incoming',
    MovementType.outgoing => 'outgoing',
    MovementType.adjustment => 'adjustment',
  };

  static MovementType _movementTypeFromWire(String value) {
    return switch (value) {
      'incoming' => MovementType.incoming,
      'outgoing' => MovementType.outgoing,
      'adjustment' => MovementType.adjustment,
      _ => throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid inventory movement response: unknown type "$value".',
        details: {'type': value},
      ),
    };
  }
}
