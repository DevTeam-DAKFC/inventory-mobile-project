import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/branch_rest_dto.dart';
import '../../dto/branch_write_request_dto.dart';

class RestApiBranchDataSource {
  const RestApiBranchDataSource(this._dio);

  final Dio _dio;

  Future<List<BranchRestDto>> getBranches({bool? isActive}) async {
    final Response<dynamic> response;
    try {
      response = isActive == null
          ? await _dio.get<dynamic>('/branches')
          : await _dio.get<dynamic>(
              '/branches',
              queryParameters: <String, dynamic>{'active': isActive},
            );
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

    final branches = data
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

    if (isActive == null) {
      return branches;
    }

    return branches
        .where((branch) => branch.isActive == isActive)
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
    try {
      final response = await _dio.patch<dynamic>(
        '/branches/$branchId/deactivate',
      );
      final branch = _parseBranchResponse(response.data);
      if (branch.isActive) {
        throw const AppException(
          code: AppErrorCode.unexpected,
          message: 'The backend did not confirm branch deactivation.',
        );
      }
      return branch;
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack);
    } on AppException {
      rethrow;
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error deactivating branch.',
        cause: e,
        stackTrace: stack,
      );
    }
  }

  Future<BranchRestDto> reactivateBranch(String branchId) async {
    try {
      final response = await _dio.patch<dynamic>(
        '/branches/$branchId/activate',
      );
      final branch = _parseBranchResponse(response.data);
      if (!branch.isActive) {
        throw const AppException(
          code: AppErrorCode.unexpected,
          message: 'El backend no confirmó la reactivación de la sucursal.',
        );
      }
      return branch;
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack);
    } on AppException {
      rethrow;
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error reactivating branch.',
        cause: e,
        stackTrace: stack,
      );
    }
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
      final errorBody = _extractErrorBody(e.response?.data);
      final serverCode = errorBody?['code'] as String?;
      final serverMessage = errorBody?['message'] as String?;

      return AppException(
        code: _statusToCode(statusCode, serverCode),
        message:
            serverMessage ??
            'Backend returned status ${statusCode ?? 'unknown'} for branches.',
        cause: e,
        stackTrace: stack,
        details: {
          'statusCode': ?statusCode,
          'serverCode': ?serverCode,
          'serverBody': ?errorBody,
        },
      );
    }

    return AppException(
      code: AppErrorCode.networkError,
      message: 'Could not load branches.',
      cause: e,
      stackTrace: stack,
    );
  }

  static Map<String, dynamic>? _extractErrorBody(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final response = Map<String, dynamic>.from(raw);
    final error = response['error'];
    if (error is Map) {
      return Map<String, dynamic>.from(error);
    }
    return null;
  }

  static AppErrorCode _statusToCode(int? statusCode, String? serverCode) {
    switch (serverCode) {
      case 'validation_error':
        return AppErrorCode.validationError;
      case 'unauthorized':
        return AppErrorCode.unauthorized;
      case 'forbidden':
        return AppErrorCode.forbidden;
      case 'not_found':
        return AppErrorCode.notFound;
      case 'conflict':
        return AppErrorCode.conflict;
      case 'service_unavailable':
        return AppErrorCode.serviceUnavailable;
    }

    return switch (statusCode) {
      400 => AppErrorCode.validationError,
      401 => AppErrorCode.unauthorized,
      403 => AppErrorCode.forbidden,
      404 => AppErrorCode.notFound,
      409 => AppErrorCode.conflict,
      503 => AppErrorCode.serviceUnavailable,
      _ => AppErrorCode.unexpected,
    };
  }
}
