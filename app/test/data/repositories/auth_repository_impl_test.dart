import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/core/storage/auth_token_storage.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_auth_data_source.dart';
import 'package:inventory_mobile/data/dto/auth_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/auth_repository_impl.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements RestApiAuthDataSource {}

class _MockTokenStorage extends Mock implements AuthTokenStorage {}

AuthLoginResponseDto _validResponse({String token = 'tok-123'}) {
  return AuthLoginResponseDto(
    accessToken: token,
    tokenType: 'Bearer',
    expiresIn: 3600,
    user: const UserDto(
      id: 'user_admin_001',
      name: 'María',
      email: 'admin@inventario-demo.com',
      role: 'admin',
      branchIds: ['branch_central'],
      isActive: true,
      createdAt: '2026-06-02T20:00:00Z',
      updatedAt: null,
    ),
  );
}

void main() {
  late _MockDataSource dataSource;
  late _MockTokenStorage storage;
  late AuthRepositoryImpl sut;
  final fixedNow = DateTime.utc(2026, 6, 2, 20, 0, 0);

  setUpAll(() {
    registerFallbackValue(
      StoredAuthToken(accessToken: '', expiresAt: DateTime.utc(2000)),
    );
    registerFallbackValue(
      const AuthRegisterRequestDto(name: '', email: '', password: ''),
    );
    registerFallbackValue(const AuthLoginRequestDto(email: '', password: ''));
  });

  setUp(() {
    dataSource = _MockDataSource();
    storage = _MockTokenStorage();
    sut = AuthRepositoryImpl(
      dataSource: dataSource,
      tokenStorage: storage,
      now: () => fixedNow,
    );
  });

  group('login', () {
    test('saves token and returns AppSuccess<AppUser> on success', () async {
      when(
        () => dataSource.login(any()),
      ).thenAnswer((_) async => _validResponse());
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      final result = await sut.login(email: 'a@b.com', password: 'pw');

      expect(result, isA<AppSuccess<AppUser>>());
      expect(result.dataOrNull?.role, UserRole.admin);

      final captured =
          verify(() => storage.saveToken(captureAny())).captured.single
              as StoredAuthToken;
      expect(captured.accessToken, 'tok-123');
      expect(
        captured.expiresAt,
        fixedNow.toUtc().add(const Duration(seconds: 3600)),
      );
    });

    test(
      'returns AppFailure and does not save token on AppException',
      () async {
        const exception = AppException(
          code: AppErrorCode.unauthorized,
          message: 'bad creds',
        );
        when(() => dataSource.login(any())).thenThrow(exception);

        final result = await sut.login(email: 'a', password: 'b');

        expect(result, isA<AppFailure<AppUser>>());
        expect(result.exceptionOrNull?.code, AppErrorCode.unauthorized);
        verifyNever(() => storage.saveToken(any()));
      },
    );

    test('wraps non-AppException errors as AppErrorCode.unexpected', () async {
      when(() => dataSource.login(any())).thenThrow(StateError('boom'));

      final result = await sut.login(email: 'a', password: 'b');

      expect(result, isA<AppFailure<AppUser>>());
      expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
      verifyNever(() => storage.saveToken(any()));
    });
  });

  group('register', () {
    test('saves token and returns AppSuccess<AppUser> on success', () async {
      when(
        () => dataSource.register(any()),
      ).thenAnswer((_) async => _validResponse(token: 'reg-tok'));
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      final result = await sut.register(
        name: 'María',
        email: 'admin@inventario-demo.com',
        password: 'pw',
      );

      expect(result, isA<AppSuccess<AppUser>>());

      final captured =
          verify(() => storage.saveToken(captureAny())).captured.single
              as StoredAuthToken;
      expect(captured.accessToken, 'reg-tok');
    });

    test('returns AppFailure on conflict and does not save token', () async {
      const exception = AppException(
        code: AppErrorCode.conflict,
        message: 'email taken',
      );
      when(() => dataSource.register(any())).thenThrow(exception);

      final result = await sut.register(name: 'n', email: 'e', password: 'p');

      expect(result.exceptionOrNull?.code, AppErrorCode.conflict);
      verifyNever(() => storage.saveToken(any()));
    });
  });

  group('logout', () {
    test('clears the token and returns AppSuccess on success', () async {
      when(() => dataSource.logout()).thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});

      final result = await sut.logout();

      expect(result, isA<AppSuccess<void>>());
      verify(() => storage.clear()).called(1);
    });

    test('still clears the token even when the data source fails', () async {
      when(() => dataSource.logout()).thenThrow(
        const AppException(code: AppErrorCode.networkError, message: 'down'),
      );
      when(() => storage.clear()).thenAnswer((_) async {});

      final result = await sut.logout();

      expect(result, isA<AppFailure<void>>());
      verify(() => storage.clear()).called(1);
    });
  });

  group('currentUser', () {
    test('returns AppSuccess with mapped user on success', () async {
      when(() => dataSource.me()).thenAnswer(
        (_) async => const UserDto(
          id: 'user_admin_001',
          name: 'María',
          email: 'admin@inventario-demo.com',
          role: 'admin',
          branchIds: ['branch_central'],
          isActive: true,
          createdAt: '2026-06-02T20:00:00Z',
          updatedAt: null,
        ),
      );

      final result = await sut.currentUser();

      expect(result.dataOrNull?.id, 'user_admin_001');
      expect(result.dataOrNull?.role, UserRole.admin);
    });

    test('returns AppFailure preserving the AppException', () async {
      const exception = AppException(
        code: AppErrorCode.unauthorized,
        message: 'no session',
      );
      when(() => dataSource.me()).thenThrow(exception);

      final result = await sut.currentUser();

      expect(result.exceptionOrNull?.code, AppErrorCode.unauthorized);
    });
  });
}
