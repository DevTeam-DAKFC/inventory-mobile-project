import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_error_mapper.dart';

DioException _exception(
  DioExceptionType type, {
  int? statusCode,
  dynamic data,
}) {
  final requestOptions = RequestOptions(path: '/test');
  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
            data: data,
          ),
  );
}

void main() {
  group('RestApiErrorMapper', () {
    test('maps timeout exceptions', () {
      final mapped = RestApiErrorMapper.mapDioException(
        exception: _exception(DioExceptionType.receiveTimeout),
        stackTrace: StackTrace.current,
        fallbackMessage: 'Failed.',
      );

      expect(mapped.code, AppErrorCode.timeout);
    });

    test('maps backend error code from ErrorResponse', () {
      final mapped = RestApiErrorMapper.mapDioException(
        exception: _exception(
          DioExceptionType.badResponse,
          statusCode: 422,
          data: {
            'code': 'insufficient_stock',
            'message': 'Not enough stock available.',
          },
        ),
        stackTrace: StackTrace.current,
        fallbackMessage: 'Failed.',
      );

      expect(mapped.code, AppErrorCode.insufficientStock);
      expect(
        mapped.message,
        'No hay stock suficiente para registrar esta salida.',
      );
    });

    test(
      'falls back to status code mapping when ErrorResponse has no code',
      () {
        final mapped = RestApiErrorMapper.mapDioException(
          exception: _exception(DioExceptionType.badResponse, statusCode: 401),
          stackTrace: StackTrace.current,
          fallbackMessage: 'Failed.',
        );

        expect(mapped.code, AppErrorCode.unauthorized);
      },
    );
  });
}
