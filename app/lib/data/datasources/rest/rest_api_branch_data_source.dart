import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/branch_rest_dto.dart';
import '../../dto/branch_write_request_dto.dart';

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

  Future<BranchRestDto> createBranch(BranchWriteRequestDto request) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>('/branches', data: request.toJson());
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack);
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error creating branch.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _parseBranchResponse(response.data);
  }

  Future<BranchRestDto> updateBranch(
    String branchId,
    BranchWriteRequestDto request,
  ) async {
    final Response<dynamic> response;
    try {
      response = await _dio.patch<dynamic>(
        '/branches/$branchId',
        data: request.toJson(),
      );
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack);
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error updating branch.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _parseBranchResponse(response.data);
  }

  Future<BranchRestDto> deactivateBranch(String branchId) async {
    final Response<dynamic> response;
    try {
      response = await _dio.patch<dynamic>('/branches/$branchId/deactivate');
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack);
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error deactivating branch.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _parseBranchResponse(response.data);
  }

  BranchRestDto _parseBranchResponse(dynamic data) {
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid branch response: payload is not a JSON object.',
        details: {'received': data},
      );
    }

    return BranchRestDto.fromJson(Map<String, dynamic>.from(data));
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
