import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/models/inventory_movement_filters.dart';
import '../../dto/inventory_movement_create_request_dto.dart';
import '../../dto/inventory_movement_rest_dto.dart';
import '../../dto/paginated_inventory_movement_rest_dto.dart';
import '../../mappers/inventory_movement_mapper.dart';
import 'rest_api_error_mapper.dart';

class RestApiInventoryMovementDataSource {
  const RestApiInventoryMovementDataSource(this._dio);

  final Dio _dio;

  Future<InventoryMovementRestDto> createMovement(
    InventoryMovementCreateRequestDto request,
  ) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '/inventory-movements',
        data: request.toJson(),
      );
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'No se pudo registrar el movimiento.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error creating inventory movement.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _movementDtoFromResponse(response.data);
  }

  Future<PaginatedInventoryMovementRestDto> getMovements(
    InventoryMovementFilters filters,
  ) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '/inventory-movements',
        queryParameters: _queryParametersFromFilters(filters),
      );
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'No se pudo cargar el historial de movimientos.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading inventory movement history.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid movement history response: payload is not an object.',
        details: {'received': data},
      );
    }
    return PaginatedInventoryMovementRestDto.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<InventoryMovementRestDto> getMovementById(String movementId) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/inventory-movements/$movementId');
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'No se pudo cargar el detalle del movimiento.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading inventory movement detail.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _movementDtoFromResponse(response.data);
  }

  Map<String, dynamic> _queryParametersFromFilters(
    InventoryMovementFilters filters,
  ) {
    return {
      if (filters.productId != null) 'productId': filters.productId,
      if (filters.branchId != null) 'branchId': filters.branchId,
      if (filters.type != null)
        'type': InventoryMovementMapper.movementTypeToWire(filters.type!),
      if (filters.userId != null) 'userId': filters.userId,
      if (filters.from != null) 'from': filters.from!.toUtc().toIso8601String(),
      if (filters.to != null) 'to': filters.to!.toUtc().toIso8601String(),
      'page': filters.page,
      'pageSize': filters.pageSize,
    };
  }

  InventoryMovementRestDto _movementDtoFromResponse(dynamic data) {
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid inventory movement response: payload is not an object.',
        details: {'received': data},
      );
    }
    return InventoryMovementRestDto.fromJson(Map<String, dynamic>.from(data));
  }
}
