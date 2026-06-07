import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_health_data_source.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _okResponse(dynamic data) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/health'),
  statusCode: 200,
  data: data,
);

DioException _dioException(DioExceptionType type, {int? statusCode}) {
  final requestOptions = RequestOptions(path: '/health');
  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
          ),
  );
}

void main() {
  late _MockDio dio;
  late RestApiHealthDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiHealthDataSource(dio);
  });

  group('checkBackendHealth', () {
    test('returns DTO on a successful JSON response', () async {
      when(() => dio.get<dynamic>('/health')).thenAnswer(
        (_) async => _okResponse(<String, dynamic>{
          'status': 'ok',
          'service': 'Inventory.Api',
        }),
      );

      final dto = await sut.checkBackendHealth();

      expect(dto.status, 'ok');
      expect(dto.service, 'Inventory.Api');
    });

    test('maps 503 badResponse to AppErrorCode.serviceUnavailable', () async {
      when(
        () => dio.get<dynamic>('/health'),
      ).thenThrow(_dioException(DioExceptionType.badResponse, statusCode: 503));

      await expectLater(
        sut.checkBackendHealth(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.serviceUnavailable,
          ),
        ),
      );
    });

    test('maps non-503 badResponse to AppErrorCode.networkError', () async {
      when(
        () => dio.get<dynamic>('/health'),
      ).thenThrow(_dioException(DioExceptionType.badResponse, statusCode: 500));

      await expectLater(
        sut.checkBackendHealth(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.networkError,
          ),
        ),
      );
    });

    test('maps connectionTimeout to AppErrorCode.timeout', () async {
      when(
        () => dio.get<dynamic>('/health'),
      ).thenThrow(_dioException(DioExceptionType.connectionTimeout));

      await expectLater(
        sut.checkBackendHealth(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.timeout,
          ),
        ),
      );
    });

    test('maps receiveTimeout to AppErrorCode.timeout', () async {
      when(
        () => dio.get<dynamic>('/health'),
      ).thenThrow(_dioException(DioExceptionType.receiveTimeout));

      await expectLater(
        sut.checkBackendHealth(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.timeout,
          ),
        ),
      );
    });

    test('maps connectionError to AppErrorCode.networkError', () async {
      when(
        () => dio.get<dynamic>('/health'),
      ).thenThrow(_dioException(DioExceptionType.connectionError));

      await expectLater(
        sut.checkBackendHealth(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.networkError,
          ),
        ),
      );
    });

    test('maps invalid JSON shape to AppErrorCode.unexpected', () async {
      when(
        () => dio.get<dynamic>('/health'),
      ).thenAnswer((_) async => _okResponse('not a json object'));

      await expectLater(
        sut.checkBackendHealth(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });

    test('maps missing field in JSON to AppErrorCode.unexpected', () async {
      when(
        () => dio.get<dynamic>('/health'),
      ).thenAnswer((_) async => _okResponse(<String, dynamic>{'status': 'ok'}));

      await expectLater(
        sut.checkBackendHealth(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });
  });
}
