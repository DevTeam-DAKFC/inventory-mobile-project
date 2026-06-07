import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/inventory_movement.dart';
import '../../domain/models/inventory_movement_create_request.dart';
import '../../domain/models/inventory_movement_filters.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/repositories/inventory_movement_repository.dart';
import '../datasources/rest/rest_api_inventory_movement_data_source.dart';
import '../mappers/inventory_movement_mapper.dart';

final class InventoryMovementRepositoryImpl
    implements InventoryMovementRepository {
  const InventoryMovementRepositoryImpl(this._dataSource);

  final RestApiInventoryMovementDataSource _dataSource;

  @override
  Future<AppResult<InventoryMovement>> createMovement(
    InventoryMovementCreateRequest request,
  ) async {
    try {
      final dto = await _dataSource.createMovement(
        InventoryMovementMapper.toCreateRequestDto(request),
      );
      return AppSuccess(InventoryMovementMapper.toDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error creating inventory movement.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<AppResult<PaginatedResult<InventoryMovement>>> getMovements(
    InventoryMovementFilters filters,
  ) async {
    try {
      final dto = await _dataSource.getMovements(filters);
      return AppSuccess(InventoryMovementMapper.toPaginatedDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading inventory movement history.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<AppResult<InventoryMovement>> getMovementById(
    String movementId,
  ) async {
    try {
      final dto = await _dataSource.getMovementById(movementId);
      return AppSuccess(InventoryMovementMapper.toDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading inventory movement detail.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
