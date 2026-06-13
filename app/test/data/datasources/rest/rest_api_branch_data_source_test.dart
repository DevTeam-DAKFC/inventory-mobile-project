import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_branch_data_source.dart';
import 'package:inventory_mobile/data/dto/branch_write_request_dto.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _okResponse(dynamic data) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/branches'),
  statusCode: 200,
  data: data,
);

Response<dynamic> _createdResponse(dynamic data) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/branches'),
  statusCode: 201,
  data: data,
);

DioException _dioException(
  DioExceptionType type, {
  int? statusCode,
  dynamic data,
}) {
  final requestOptions = RequestOptions(path: '/branches');
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

    test('sends active status filter and parses list response', () async {
      when(
        () => dio.get<dynamic>('/branches', queryParameters: {'active': false}),
      ).thenAnswer(
        (_) async => _okResponse([
          {
            'id': 2,
            'name': 'Sucursal Cerrada',
            'address': null,
            'isActive': false,
          },
        ]),
      );

      final branches = await sut.getBranches(isActive: false);

      expect(branches.single.isActive, isFalse);
    });

    test(
      'filters out branches that do not match the requested status',
      () async {
        when(
          () =>
              dio.get<dynamic>('/branches', queryParameters: {'active': false}),
        ).thenAnswer(
          (_) async => _okResponse([
            {
              'id': 1,
              'name': 'Sucursal Activa',
              'address': null,
              'isActive': true,
            },
            {
              'id': 2,
              'name': 'Sucursal Inactiva',
              'address': null,
              'isActive': false,
            },
          ]),
        );

        final branches = await sut.getBranches(isActive: false);

        expect(branches, hasLength(1));
        expect(branches.single.name, 'Sucursal Inactiva');
      },
    );

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

    for (final entry in <int, AppErrorCode>{
      400: AppErrorCode.validationError,
      403: AppErrorCode.forbidden,
      404: AppErrorCode.notFound,
      409: AppErrorCode.conflict,
      503: AppErrorCode.serviceUnavailable,
      500: AppErrorCode.unexpected,
    }.entries) {
      test('maps ${entry.key} badResponse to ${entry.value.value}', () async {
        when(() => dio.get<dynamic>('/branches')).thenThrow(
          _dioException(DioExceptionType.badResponse, statusCode: entry.key),
        );

        await expectLater(
          sut.getBranches(),
          throwsA(
            isA<AppException>().having(
              (error) => error.code,
              'code',
              entry.value,
            ),
          ),
        );
      });
    }

    test('preserves backend conflict message', () async {
      when(() => dio.get<dynamic>('/branches')).thenThrow(
        _dioException(
          DioExceptionType.badResponse,
          statusCode: 409,
          data: {
            'error': {
              'code': 'conflict',
              'message': 'Ya existe una sucursal con ese nombre.',
            },
          },
        ),
      );

      await expectLater(
        sut.getBranches(),
        throwsA(
          isA<AppException>()
              .having((error) => error.code, 'code', AppErrorCode.conflict)
              .having(
                (error) => error.message,
                'message',
                'Ya existe una sucursal con ese nombre.',
              ),
        ),
      );
    });

    test('maps connectionError to networkError', () async {
      when(
        () => dio.get<dynamic>('/branches'),
      ).thenThrow(_dioException(DioExceptionType.connectionError));

      await expectLater(
        sut.getBranches(),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            AppErrorCode.networkError,
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

  group('createBranch', () {
    test('posts request body and parses created branch', () async {
      when(
        () => dio.post<dynamic>('/branches', data: any<dynamic>(named: 'data')),
      ).thenAnswer(
        (_) async => _createdResponse({
          'id': 1,
          'name': 'Sucursal Central',
          'address': 'San Jose centro',
          'isActive': true,
        }),
      );

      final branch = await sut.createBranch(
        const BranchWriteRequestDto(
          name: ' Sucursal Central ',
          address: ' San Jose centro ',
        ),
      );

      expect(branch.id, '1');
      expect(branch.name, 'Sucursal Central');
      final captured =
          verify(
                () => dio.post<dynamic>(
                  '/branches',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured, {
        'name': 'Sucursal Central',
        'address': 'San Jose centro',
      });
    });
  });

  group('updateBranch', () {
    test('patches branch and parses response', () async {
      when(
        () => dio.patch<dynamic>(
          '/branches/1',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _okResponse({
          'id': 1,
          'name': 'Sucursal Norte',
          'address': null,
          'isActive': true,
        }),
      );

      final branch = await sut.updateBranch(
        '1',
        const BranchWriteRequestDto(name: 'Sucursal Norte', address: ''),
      );

      expect(branch.name, 'Sucursal Norte');
      expect(branch.address, isNull);
      final captured =
          verify(
                () => dio.patch<dynamic>(
                  '/branches/1',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured, {'name': 'Sucursal Norte', 'address': null});
    });
  });

  group('deactivateBranch', () {
    test('patches deactivate endpoint and parses response', () async {
      when(() => dio.patch<dynamic>('/branches/1/deactivate')).thenAnswer(
        (_) async => _okResponse({
          'id': 1,
          'name': 'Sucursal Central',
          'address': 'San Jose centro',
          'isActive': false,
        }),
      );

      final branch = await sut.deactivateBranch('1');

      expect(branch.isActive, isFalse);
    });
  });

  group('reactivateBranch', () {
    test('patches activate endpoint and validates active response', () async {
      when(() => dio.patch<dynamic>('/branches/1/activate')).thenAnswer(
        (_) async => _okResponse({
          'id': 1,
          'name': 'Sucursal Central',
          'address': 'San Jose centro',
          'isActive': true,
        }),
      );

      await expectLater(sut.reactivateBranch('1'), completes);
    });

    test('fails when backend ignores the requested active state', () async {
      when(() => dio.patch<dynamic>('/branches/1/activate')).thenAnswer(
        (_) async => _okResponse({
          'id': 1,
          'name': 'Sucursal Central',
          'address': 'San Jose centro',
          'isActive': false,
        }),
      );

      await expectLater(
        sut.reactivateBranch('1'),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            contains('no confirmó la reactivación'),
          ),
        ),
      );
    });
  });
}
