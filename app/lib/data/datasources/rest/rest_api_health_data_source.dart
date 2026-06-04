import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/backend_health_rest_dto.dart';

/// REST data source for the inventory backend health endpoint.
///
/// Converts raw Dio failures into the shared [AppException] taxonomy so
/// repositories never observe transport-specific errors.
class RestApiHealthDataSource {
  const RestApiHealthDataSource(this._dio);

  final Dio _dio;

  Future<BackendHealthRestDto> checkBackendHealth() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/health');
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack);
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error checking backend health.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid health response: payload is not a JSON object.',
        details: {'received': data},
      );
    }
    // JSON-decoded maps from Dio carry String keys, but the runtime type may
    // be Map<dynamic, dynamic> depending on the decoder — coerce defensively.
    return BackendHealthRestDto.fromJson(Map<String, dynamic>.from(data));
  }

  AppException _mapDioException(DioException e, StackTrace stack) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          code: AppErrorCode.timeout,
          message: 'Backend health check timed out.',
          cause: e,
          stackTrace: stack,
        );
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 503) {
          return AppException(
            code: AppErrorCode.serviceUnavailable,
            message: 'Backend reported service unavailable.',
            cause: e,
            stackTrace: stack,
          );
        }
        return AppException(
          code: AppErrorCode.networkError,
          message:
              'Backend returned unexpected status ${e.response?.statusCode}.',
          cause: e,
          stackTrace: stack,
        );
      case DioExceptionType.connectionError:
        return AppException(
          code: AppErrorCode.networkError,
          message: 'Cannot reach the backend.',
          cause: e,
          stackTrace: stack,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppException(
          code: AppErrorCode.networkError,
          message: 'Backend health check failed: ${e.message ?? 'unknown'}.',
          cause: e,
          stackTrace: stack,
        );
    }
  }
}
