import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/auth_rest_dto.dart';

/// REST data source for the inventory backend auth endpoints.
///
/// Converts raw Dio failures into the shared [AppException] taxonomy so
/// repositories never observe transport-specific errors.
class RestApiAuthDataSource {
  const RestApiAuthDataSource(this._dio);

  final Dio _dio;

  Future<AuthLoginResponseDto> register(AuthRegisterRequestDto request) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '/auth/register',
        data: request.toJson(),
      );
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack, endpoint: '/auth/register');
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error during registration.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _parseLoginResponse(response.data, endpoint: '/auth/register');
  }

  Future<AuthLoginResponseDto> login(AuthLoginRequestDto request) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '/auth/login',
        data: request.toJson(),
      );
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack, endpoint: '/auth/login');
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error during login.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _parseLoginResponse(response.data, endpoint: '/auth/login');
  }

  Future<UserDto> me() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/auth/me');
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack, endpoint: '/auth/me');
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error fetching current user.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid /auth/me response: payload is not a JSON object.',
        details: {'received': data},
      );
    }
    return UserDto.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> logout() async {
    try {
      await _dio.post<dynamic>('/auth/logout');
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack, endpoint: '/auth/logout');
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error during logout.',
        cause: e,
        stackTrace: stack,
      );
    }
  }

  AuthLoginResponseDto _parseLoginResponse(
    dynamic data, {
    required String endpoint,
  }) {
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid $endpoint response: payload is not a JSON object.',
        details: {'received': data},
      );
    }
    return AuthLoginResponseDto.fromJson(Map<String, dynamic>.from(data));
  }

  AppException _mapDioException(
    DioException e,
    StackTrace stack, {
    required String endpoint,
  }) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          code: AppErrorCode.timeout,
          message: 'Request to $endpoint timed out.',
          cause: e,
          stackTrace: stack,
        );
      case DioExceptionType.badResponse:
        return _mapBadResponse(e, stack, endpoint: endpoint);
      case DioExceptionType.connectionError:
        return AppException(
          code: AppErrorCode.networkError,
          message: 'Cannot reach the backend ($endpoint).',
          cause: e,
          stackTrace: stack,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppException(
          code: AppErrorCode.networkError,
          message: 'Request to $endpoint failed: ${e.message ?? 'unknown'}.',
          cause: e,
          stackTrace: stack,
        );
    }
  }

  AppException _mapBadResponse(
    DioException e,
    StackTrace stack, {
    required String endpoint,
  }) {
    final statusCode = e.response?.statusCode;
    final body = _extractErrorBody(e.response?.data);
    final serverMessage = body?['message'] as String?;
    final serverCode = body?['code'] as String?;
    final details = <String, Object?>{
      'statusCode': ?statusCode,
      'serverCode': ?serverCode,
      'serverBody': ?body,
    };
    final code = _statusToCode(statusCode, serverCode);
    final message =
        serverMessage ??
        'Backend returned status ${statusCode ?? 'unknown'} for $endpoint.';
    return AppException(
      code: code,
      message: message,
      cause: e,
      stackTrace: stack,
      details: details.isEmpty ? null : details,
    );
  }

  static Map<String, dynamic>? _extractErrorBody(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final asMap = Map<String, dynamic>.from(raw);
    final error = asMap['error'];
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
    switch (statusCode) {
      case 400:
        return AppErrorCode.validationError;
      case 401:
        return AppErrorCode.unauthorized;
      case 403:
        return AppErrorCode.forbidden;
      case 404:
        return AppErrorCode.notFound;
      case 409:
        return AppErrorCode.conflict;
      case 503:
        return AppErrorCode.serviceUnavailable;
      default:
        return AppErrorCode.networkError;
    }
  }
}
