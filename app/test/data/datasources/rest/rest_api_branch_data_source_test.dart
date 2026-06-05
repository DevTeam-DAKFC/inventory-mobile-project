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
}
