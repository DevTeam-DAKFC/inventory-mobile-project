import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/branch_rest_dto.dart';

class RestApiBranchDataSource {
  const RestApiBranchDataSource(this._dio);

  final Dio _dio;

  Future<List<BranchRestDto>> getBranches() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/branches');
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack);
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading branches.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! List) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid branches response: payload is not a JSON list.',
        details: {'received': data},
      );
    }

    return data
        .map((item) {
          if (item is! Map) {
            throw AppException(
              code: AppErrorCode.unexpected,
              message:
                  'Invalid branches response: list item is not a JSON object.',
              details: {'received': item},
            );
          }
          return BranchRestDto.fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  AppException _mapDioException(DioException e, StackTrace stack) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AppException(
        code: AppErrorCode.timeout,
        message: 'Loading branches timed out.',
        cause: e,
        stackTrace: stack,
      );
    }

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final code = switch (statusCode) {
        401 => AppErrorCode.unauthorized,
        403 => AppErrorCode.forbidden,
        404 => AppErrorCode.notFound,
        503 => AppErrorCode.serviceUnavailable,
        _ => AppErrorCode.networkError,
      };

      return AppException(
        code: code,
        message: 'Backend returned unexpected status $statusCode.',
        cause: e,
        stackTrace: stack,
      );
    }

    return AppException(
      code: AppErrorCode.networkError,
      message: 'Could not load branches.',
      cause: e,
      stackTrace: stack,
    );
  }
}
