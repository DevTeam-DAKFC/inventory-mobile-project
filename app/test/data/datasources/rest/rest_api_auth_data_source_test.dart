import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_auth_data_source.dart';
import 'package:inventory_mobile/data/dto/auth_rest_dto.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _okResponse(
  String path,
  dynamic data, {
  int statusCode = 200,
}) => Response<dynamic>(
  requestOptions: RequestOptions(path: path),
  statusCode: statusCode,
  data: data,
);

DioException _dioException(
  String path,
  DioExceptionType type, {
  int? statusCode,
  dynamic body,
}) {
  final requestOptions = RequestOptions(path: path);
  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
            data: body,
          ),
  );
}

Map<String, dynamic> _validLoginResponse() => <String, dynamic>{
  'accessToken': 'tok-123',
  'tokenType': 'Bearer',
  'expiresIn': 3600,
  'user': <String, dynamic>{
    'id': 'user_admin_001',
    'name': 'María',
    'email': 'admin@inventario-demo.com',
    'role': 'admin',
    'branchIds': ['branch_central'],
    'isActive': true,
    'createdAt': '2026-06-02T20:00:00Z',
    'updatedAt': null,
  },
};

void main() {
  late _MockDio dio;
  late RestApiAuthDataSource sut;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    dio = _MockDio();
    sut = RestApiAuthDataSource(dio);
  });

  group('login', () {
    test('returns DTO on a successful response', () async {
      when(
        () => dio.post<dynamic>('/auth/login', data: any(named: 'data')),
      ).thenAnswer(
        (_) async => _okResponse('/auth/login', _validLoginResponse()),
      );

      final dto = await sut.login(
        const AuthLoginRequestDto(email: 'a@b.com', password: 'pw'),
      );

      expect(dto.accessToken, 'tok-123');
      expect(dto.expiresIn, 3600);
      expect(dto.user.id, 'user_admin_001');
    });

    test('maps 401 with code unauthorized via server body', () async {
      when(
        () => dio.post<dynamic>('/auth/login', data: any(named: 'data')),
      ).thenThrow(
        _dioException(
          '/auth/login',
          DioExceptionType.badResponse,
          statusCode: 401,
          body: {
            'error': {
              'code': 'unauthorized',
              'message': 'Invalid email or password.',
            },
          },
        ),
      );

      await expectLater(
        sut.login(const AuthLoginRequestDto(email: 'a', password: 'b')),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unauthorized,
          ),
        ),
      );
    });

    test('maps connectionTimeout to AppErrorCode.timeout', () async {
      when(
        () => dio.post<dynamic>('/auth/login', data: any(named: 'data')),
      ).thenThrow(
        _dioException('/auth/login', DioExceptionType.connectionTimeout),
      );

      await expectLater(
        sut.login(const AuthLoginRequestDto(email: 'a', password: 'b')),
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
        () => dio.post<dynamic>('/auth/login', data: any(named: 'data')),
      ).thenThrow(
        _dioException('/auth/login', DioExceptionType.connectionError),
      );

      await expectLater(
        sut.login(const AuthLoginRequestDto(email: 'a', password: 'b')),
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
        () => dio.post<dynamic>('/auth/login', data: any(named: 'data')),
      ).thenAnswer((_) async => _okResponse('/auth/login', 'not-json'));

      await expectLater(
        sut.login(const AuthLoginRequestDto(email: 'a', password: 'b')),
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

  group('register', () {
    test('returns DTO on a successful 201 response', () async {
      when(
        () => dio.post<dynamic>('/auth/register', data: any(named: 'data')),
      ).thenAnswer(
        (_) async => _okResponse(
          '/auth/register',
          _validLoginResponse(),
          statusCode: 201,
        ),
      );

      final dto = await sut.register(
        const AuthRegisterRequestDto(
          name: 'María',
          email: 'admin@inventario-demo.com',
          password: 'pw',
        ),
      );

      expect(dto.accessToken, 'tok-123');
      expect(dto.user.id, 'user_admin_001');
    });

    test('maps 409 conflict via server body', () async {
      when(
        () => dio.post<dynamic>('/auth/register', data: any(named: 'data')),
      ).thenThrow(
        _dioException(
          '/auth/register',
          DioExceptionType.badResponse,
          statusCode: 409,
          body: {
            'error': {
              'code': 'conflict',
              'message': 'Email already registered.',
            },
          },
        ),
      );

      await expectLater(
        sut.register(
          const AuthRegisterRequestDto(name: 'a', email: 'a', password: 'b'),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.conflict,
          ),
        ),
      );
    });

    test('maps 400 validation_error via server body', () async {
      when(
        () => dio.post<dynamic>('/auth/register', data: any(named: 'data')),
      ).thenThrow(
        _dioException(
          '/auth/register',
          DioExceptionType.badResponse,
          statusCode: 400,
          body: {
            'error': {'code': 'validation_error', 'message': 'Invalid fields.'},
          },
        ),
      );

      await expectLater(
        sut.register(
          const AuthRegisterRequestDto(name: 'a', email: 'a', password: 'b'),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.validationError,
          ),
        ),
      );
    });
  });

  group('me', () {
    test('returns UserDto on a successful response', () async {
      when(() => dio.get<dynamic>('/auth/me')).thenAnswer(
        (_) async => _okResponse('/auth/me', _validLoginResponse()['user']),
      );

      final dto = await sut.me();

      expect(dto.id, 'user_admin_001');
      expect(dto.role, 'admin');
    });

    test('maps 401 to AppErrorCode.unauthorized', () async {
      when(() => dio.get<dynamic>('/auth/me')).thenThrow(
        _dioException(
          '/auth/me',
          DioExceptionType.badResponse,
          statusCode: 401,
        ),
      );

      await expectLater(
        sut.me(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unauthorized,
          ),
        ),
      );
    });

    test('maps invalid payload to AppErrorCode.unexpected', () async {
      when(
        () => dio.get<dynamic>('/auth/me'),
      ).thenAnswer((_) async => _okResponse('/auth/me', 'not-json'));

      await expectLater(
        sut.me(),
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

  group('logout', () {
    test('completes normally on success', () async {
      when(() => dio.post<dynamic>('/auth/logout')).thenAnswer(
        (_) async => _okResponse('/auth/logout', null, statusCode: 204),
      );

      await sut.logout();

      verify(() => dio.post<dynamic>('/auth/logout')).called(1);
    });

    test('maps 401 to AppErrorCode.unauthorized', () async {
      when(() => dio.post<dynamic>('/auth/logout')).thenThrow(
        _dioException(
          '/auth/logout',
          DioExceptionType.badResponse,
          statusCode: 401,
        ),
      );

      await expectLater(
        sut.logout(),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unauthorized,
          ),
        ),
      );
    });
  });
}
