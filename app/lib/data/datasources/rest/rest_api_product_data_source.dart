import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/paginated_product_rest_dto.dart';
import 'rest_api_error_mapper.dart';

class RestApiProductDataSource {
  const RestApiProductDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedProductRestDto> getProducts({
    bool? isActive,
    int page = 1,
    int pageSize = 100,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '/products',
        queryParameters: {
          'isActive': ?isActive,
          'page': page,
          'pageSize': pageSize,
        },
      );
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'Unable to load products.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading products.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid products response: payload is not an object.',
        details: {'received': data},
      );
    }
    return PaginatedProductRestDto.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> activateProduct(String productId) async {
    await _patchProductState(
      productId: productId,
      path: '/products/$productId/activate',
      fallbackMessage: 'Unable to activate product.',
      unexpectedMessage: 'Unexpected error activating product.',
    );
  }

  Future<void> deactivateProduct(String productId) async {
    await _patchProductState(
      productId: productId,
      path: '/products/$productId/deactivate',
      fallbackMessage: 'Unable to deactivate product.',
      unexpectedMessage: 'Unexpected error deactivating product.',
    );
  }

  Future<void> _patchProductState({
    required String productId,
    required String path,
    required String fallbackMessage,
    required String unexpectedMessage,
  }) async {
    try {
      await _dio.patch<dynamic>(path);
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: fallbackMessage,
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: unexpectedMessage,
        details: {'productId': productId},
        cause: e,
        stackTrace: stack,
      );
    }
  }
}
