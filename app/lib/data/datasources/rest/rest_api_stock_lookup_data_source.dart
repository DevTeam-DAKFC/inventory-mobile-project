import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/stock_lookup_rest_dto.dart';
import 'rest_api_error_mapper.dart';

class RestApiStockLookupDataSource {
  const RestApiStockLookupDataSource(this._dio);

  final Dio _dio;

  Future<StockLookupRestDto> getStockLookup({
    required String productId,
    required String branchId,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '/stock/lookup',
        queryParameters: {'productId': productId, 'branchId': branchId},
      );
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'No se pudo cargar el stock actual.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading stock lookup.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid stock lookup response: payload is not an object.',
        details: {'received': data},
      );
    }
    return StockLookupRestDto.fromJson(Map<String, dynamic>.from(data));
  }
}
