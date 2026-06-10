import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';

final class RestApiErrorMapper {
  const RestApiErrorMapper._();

  static AppException mapDioException({
    required DioException exception,
    required StackTrace stackTrace,
    required String fallbackMessage,
  }) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          code: AppErrorCode.timeout,
          message: '$fallbackMessage La solicitud agoto el tiempo de espera.',
          cause: exception,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        return _mapBadResponse(exception, stackTrace, fallbackMessage);
      case DioExceptionType.connectionError:
        return AppException(
          code: AppErrorCode.networkError,
          message: '$fallbackMessage No se pudo conectar con el backend.',
          cause: exception,
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppException(
          code: AppErrorCode.networkError,
          message:
              '$fallbackMessage ${exception.message ?? 'Error desconocido.'}',
          cause: exception,
          stackTrace: stackTrace,
        );
    }
  }

  static AppException _mapBadResponse(
    DioException exception,
    StackTrace stackTrace,
    String fallbackMessage,
  ) {
    final response = exception.response;
    final code =
        _errorCodeFromResponse(response) ??
        _fallbackCodeForStatus(response?.statusCode);

    return AppException(
      code: code,
      message:
          _messageFromResponse(response) ??
          '$fallbackMessage El backend respondio con estado '
              '${response?.statusCode}.',
      cause: exception,
      stackTrace: stackTrace,
      details: {'statusCode': response?.statusCode},
    );
  }

  static AppErrorCode? _errorCodeFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is! Map) return null;

    final rawCode = data['code'];
    if (rawCode is! String) return null;

    for (final code in AppErrorCode.values) {
      if (code.value == rawCode) return code;
    }
    return null;
  }

  static String? _messageFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is! Map) return null;

    final message = data['message'];
    if (message is! String || message.trim().isEmpty) return null;

    return _localizedBackendMessage(message.trim());
  }

  static String _localizedBackendMessage(String message) {
    return switch (message) {
      'Stock was not found for the requested product and branch.' =>
        'No existe stock para el producto y la sucursal seleccionados.',
      'Not enough stock available.' =>
        'No hay stock suficiente para registrar esta salida.',
      _ => message,
    };
  }

  static AppErrorCode _fallbackCodeForStatus(int? statusCode) {
    return switch (statusCode) {
      400 => AppErrorCode.validationError,
      401 => AppErrorCode.unauthorized,
      403 => AppErrorCode.forbidden,
      404 => AppErrorCode.notFound,
      409 => AppErrorCode.conflict,
      422 => AppErrorCode.validationError,
      503 => AppErrorCode.serviceUnavailable,
      _ => AppErrorCode.networkError,
    };
  }
}
