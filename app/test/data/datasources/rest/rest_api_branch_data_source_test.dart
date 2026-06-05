import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_branch_data_source.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _okResponse(dynamic data) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/branches'),
  statusCode: 200,
  data: data,
);

DioException _dioException(DioExceptionType type, {int? statusCode}) {
  final requestOptions = RequestOptions(path: '/branches');
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
  late RestApiBranchDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiBranchDataSource(dio);
  });

  group('getBranches', () {
    test('returns DTOs on a successful JSON list response', () async {
      when(() => dio.get<dynamic>('/branches')).thenAnswer(
        (_) async => _okResponse([
          {
            'id': 1,
            'name': 'Sucursal Central',
            'address': 'San Jose centro',
            'isActive': true,
          },
        ]),
      );

      final branches = await sut.getBranches();

      expect(branches, hasLength(1));
      expect(branches.single.id, '1');
      expect(branches.single.name, 'Sucursal Central');
    });

    test('maps 401 badResponse to unauthorized', () async {
      when(
        () => dio.get<dynamic>('/branches'),
      ).thenThrow(_dioException(DioExceptionType.badResponse, statusCode: 401));

      await expectLater(
        sut.getBranches(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unauthorized,
          ),
        ),
      );
    });

    test('maps connectionTimeout to timeout', () async {
      when(
        () => dio.get<dynamic>('/branches'),
      ).thenThrow(_dioException(DioExceptionType.connectionTimeout));

      await expectLater(
        sut.getBranches(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.timeout,
          ),
        ),
      );
    });

    test('maps invalid JSON shape to unexpected', () async {
      when(
        () => dio.get<dynamic>('/branches'),
      ).thenAnswer((_) async => _okResponse({'id': 1}));

      await expectLater(
        sut.getBranches(),
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
