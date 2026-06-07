import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';

/// Converts Dio and structured backend failures into the shared error surface.
final class RestErrorParser {
  const RestErrorParser._();

  static AppException fromDio(DioException error, StackTrace stackTrace) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          code: AppErrorCode.timeout,
          message: 'The backend request timed out.',
          cause: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        return _fromResponse(error, stackTrace);
      case DioExceptionType.connectionError:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppException(
          code: AppErrorCode.networkError,
          message: 'Could not complete the backend request.',
          cause: error,
          stackTrace: stackTrace,
        );
    }
  }

  static AppException _fromResponse(
    DioException dioError,
    StackTrace stackTrace,
  ) {
    final data = dioError.response?.data;
    final envelope = _stringKeyedMap(data);
    if (envelope != null) {
      final rawError = envelope['error'];
      final error = _stringKeyedMap(rawError);
      if (error != null) {
        final code = error['code'];
        final message = error['message'];
        if (code is String && message is String) {
          final details = <String, Object?>{'backendCode': code};
          final rawDetails = error['details'];
          if (rawDetails is List) {
            details['fieldErrors'] = rawDetails
                .map(_stringKeyedMap)
                .whereType<Map<String, dynamic>>()
                .toList(growable: false);
          }
          final requestId = error['requestId'];
          if (requestId is String) details['requestId'] = requestId;

          return AppException(
            code: _parseCode(code),
            message: message,
            cause: dioError,
            stackTrace: stackTrace,
            details: details.isEmpty ? null : details,
          );
        }
      }
    }

    return AppException(
      code: _statusCodeFallback(dioError.response?.statusCode),
      message: 'The backend returned an invalid error response.',
      cause: dioError,
      stackTrace: stackTrace,
      details: {'received': data},
    );
  }

  static Map<String, dynamic>? _stringKeyedMap(Object? value) {
    if (value is! Map) return null;
    if (value.keys.any((key) => key is! String)) return null;
    return Map<String, dynamic>.from(value);
  }

  static AppErrorCode _parseCode(String value) {
    for (final code in AppErrorCode.values) {
      if (code.value == value) return code;
    }
    return AppErrorCode.unexpected;
  }

  static AppErrorCode _statusCodeFallback(int? statusCode) =>
      switch (statusCode) {
        401 => AppErrorCode.unauthorized,
        403 => AppErrorCode.forbidden,
        404 => AppErrorCode.notFound,
        409 => AppErrorCode.conflict,
        503 => AppErrorCode.serviceUnavailable,
        _ => AppErrorCode.unexpected,
      };
}
