import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_error_parser.dart';

void main() {
  group('RestErrorParser', () {
    test('preserves structured conflict field errors and requestId', () {
      final exception = RestErrorParser.fromDio(
        _badResponse(409, <String, dynamic>{
          'error': <String, dynamic>{
            'code': 'conflict',
            'message': 'Duplicate product.',
            'details': [
              <String, dynamic>{'field': 'sku', 'message': 'SKU exists.'},
              <String, dynamic>{
                'field': 'barcode',
                'message': 'Barcode exists.',
              },
            ],
            'requestId': 'request-1',
          },
        }),
        StackTrace.current,
      );

      expect(exception.code, AppErrorCode.conflict);
      expect(exception.message, 'Duplicate product.');
      expect(exception.details?['backendCode'], 'conflict');
      expect(exception.details?['requestId'], 'request-1');
      expect(exception.details?['fieldErrors'], isA<List<dynamic>>());
      expect(exception.details?['fieldErrors'].toString(), contains('barcode'));
    });

    test('maps validation_error and not_found backend codes', () {
      final validation = RestErrorParser.fromDio(
        _structuredError('validation_error'),
        StackTrace.current,
      );
      final notFound = RestErrorParser.fromDio(
        _structuredError('not_found'),
        StackTrace.current,
      );

      expect(validation.code, AppErrorCode.validationError);
      expect(notFound.code, AppErrorCode.notFound);
    });

    test('maps network and timeout failures separately', () {
      final network = RestErrorParser.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/products'),
          type: DioExceptionType.connectionError,
        ),
        StackTrace.current,
      );
      final timeout = RestErrorParser.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/products'),
          type: DioExceptionType.receiveTimeout,
        ),
        StackTrace.current,
      );

      expect(network.code, AppErrorCode.networkError);
      expect(timeout.code, AppErrorCode.timeout);
    });

    test('maps malformed backend error response to unexpected', () {
      final exception = RestErrorParser.fromDio(
        _badResponse(500, 'invalid'),
        StackTrace.current,
      );

      expect(exception.code, AppErrorCode.unexpected);
      expect(exception.details?['received'], 'invalid');
    });

    test('does not throw while parsing maps with non-string keys', () {
      final exception = RestErrorParser.fromDio(
        _badResponse(500, <Object, Object>{1: 'invalid'}),
        StackTrace.current,
      );

      expect(exception.code, AppErrorCode.unexpected);
    });

    test('ignores malformed field details without throwing', () {
      final exception = RestErrorParser.fromDio(
        _badResponse(409, <String, dynamic>{
          'error': <String, dynamic>{
            'code': 'conflict',
            'message': 'Duplicate product.',
            'details': [
              <Object, Object>{1: 'invalid'},
              <String, dynamic>{'field': 'sku', 'message': 'duplicate'},
            ],
          },
        }),
        StackTrace.current,
      );

      expect(exception.code, AppErrorCode.conflict);
      expect(exception.details?['fieldErrors'], hasLength(1));
    });
  });
}

DioException _structuredError(String code) =>
    _badResponse(code == 'not_found' ? 404 : 400, <String, dynamic>{
      'error': <String, dynamic>{'code': code, 'message': 'Backend message.'},
    });

DioException _badResponse(int statusCode, dynamic data) {
  final options = RequestOptions(path: '/products');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}
