import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/core/storage/auth_token_storage.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';
import 'package:inventory_mobile/domain/repositories/auth_repository.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/navigation/session_restore_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenStorage extends Mock implements AuthTokenStorage {}

class _MockAuthRepository extends Mock implements AuthRepository {}

AppUser _user({required UserRole role}) {
  return AppUser(
    id: role == UserRole.admin ? 'admin_1' : 'collab_1',
    name: 'Test User',
    email: 'user@example.com',
    role: role,
    branchIds: const ['branch_central'],
    isActive: true,
    createdAt: DateTime.utc(2026, 6, 2, 20),
  );
}

void main() {
  late _MockTokenStorage tokenStorage;
  late _MockAuthRepository authRepository;
  late AppSession appSession;
  final fixedNow = DateTime.utc(2026, 6, 2, 20, 0, 0);

  SessionRestoreController buildSut() {
    return SessionRestoreController(
      tokenStorage: tokenStorage,
      authRepository: authRepository,
      appSession: appSession,
      now: () => fixedNow,
    );
  }

  setUp(() {
    tokenStorage = _MockTokenStorage();
    authRepository = _MockAuthRepository();
    appSession = AppSession();
  });

  group('restore — no token', () {
    test('completes without calling currentUser or clearing storage', () async {
      when(() => tokenStorage.readToken()).thenAnswer((_) async => null);

      await buildSut().restore();

      expect(appSession.isAuthenticated, isFalse);
      expect(appSession.user, isNull);
      verifyNever(() => authRepository.currentUser());
      verifyNever(() => tokenStorage.clear());
    });
  });

  group('restore — expired token', () {
    test('clears the token and does not call currentUser', () async {
      when(() => tokenStorage.readToken()).thenAnswer(
        (_) async => StoredAuthToken(
          accessToken: 'expired-tok',
          expiresAt: fixedNow.subtract(const Duration(seconds: 1)),
        ),
      );
      when(() => tokenStorage.clear()).thenAnswer((_) async {});

      await buildSut().restore();

      expect(appSession.isAuthenticated, isFalse);
      expect(appSession.user, isNull);
      verifyNever(() => authRepository.currentUser());
      verify(() => tokenStorage.clear()).called(1);
    });

    test('treats expiresAt equal to now as expired', () async {
      when(() => tokenStorage.readToken()).thenAnswer(
        (_) async =>
            StoredAuthToken(accessToken: 'edge-tok', expiresAt: fixedNow),
      );
      when(() => tokenStorage.clear()).thenAnswer((_) async {});

      await buildSut().restore();

      verifyNever(() => authRepository.currentUser());
      verify(() => tokenStorage.clear()).called(1);
    });
  });

  group('restore — valid token, currentUser succeeds', () {
    test('admin user authenticates the session with admin role', () async {
      final admin = _user(role: UserRole.admin);
      when(() => tokenStorage.readToken()).thenAnswer(
        (_) async => StoredAuthToken(
          accessToken: 'tok',
          expiresAt: fixedNow.add(const Duration(hours: 1)),
        ),
      );
      when(
        () => authRepository.currentUser(),
      ).thenAnswer((_) async => AppSuccess(admin));

      await buildSut().restore();

      expect(appSession.isAuthenticated, isTrue);
      expect(appSession.user, same(admin));
      expect(appSession.role, SessionRole.admin);
      expect(appSession.canViewAdminEntries, isTrue);
      verifyNever(() => tokenStorage.clear());
    });

    test('collaborator user authenticates as collaborator', () async {
      final collaborator = _user(role: UserRole.collaborator);
      when(() => tokenStorage.readToken()).thenAnswer(
        (_) async => StoredAuthToken(
          accessToken: 'tok',
          expiresAt: fixedNow.add(const Duration(hours: 1)),
        ),
      );
      when(
        () => authRepository.currentUser(),
      ).thenAnswer((_) async => AppSuccess(collaborator));

      await buildSut().restore();

      expect(appSession.isAuthenticated, isTrue);
      expect(appSession.user, same(collaborator));
      expect(appSession.role, SessionRole.collaborator);
      expect(appSession.canViewAdminEntries, isFalse);
      verifyNever(() => tokenStorage.clear());
    });
  });

  group('restore — valid token, currentUser fails', () {
    test(
      'unauthorized clears token and leaves session unauthenticated',
      () async {
        when(() => tokenStorage.readToken()).thenAnswer(
          (_) async => StoredAuthToken(
            accessToken: 'tok',
            expiresAt: fixedNow.add(const Duration(hours: 1)),
          ),
        );
        when(() => authRepository.currentUser()).thenAnswer(
          (_) async => const AppFailure(
            AppException(
              code: AppErrorCode.unauthorized,
              message: 'expired session',
            ),
          ),
        );
        when(() => tokenStorage.clear()).thenAnswer((_) async {});

        await buildSut().restore();

        expect(appSession.isAuthenticated, isFalse);
        expect(appSession.user, isNull);
        verify(() => tokenStorage.clear()).called(1);
      },
    );

    test(
      'networkError keeps token and leaves session unauthenticated',
      () async {
        when(() => tokenStorage.readToken()).thenAnswer(
          (_) async => StoredAuthToken(
            accessToken: 'tok',
            expiresAt: fixedNow.add(const Duration(hours: 1)),
          ),
        );
        when(() => authRepository.currentUser()).thenAnswer(
          (_) async => const AppFailure(
            AppException(
              code: AppErrorCode.networkError,
              message: 'no network',
            ),
          ),
        );

        await buildSut().restore();

        expect(appSession.isAuthenticated, isFalse);
        expect(appSession.user, isNull);
        verifyNever(() => tokenStorage.clear());
      },
    );

    test('timeout keeps token and leaves session unauthenticated', () async {
      when(() => tokenStorage.readToken()).thenAnswer(
        (_) async => StoredAuthToken(
          accessToken: 'tok',
          expiresAt: fixedNow.add(const Duration(hours: 1)),
        ),
      );
      when(() => authRepository.currentUser()).thenAnswer(
        (_) async => const AppFailure(
          AppException(code: AppErrorCode.timeout, message: 'timed out'),
        ),
      );

      await buildSut().restore();

      expect(appSession.isAuthenticated, isFalse);
      verifyNever(() => tokenStorage.clear());
    });

    test(
      'serviceUnavailable keeps token and leaves session unauthenticated',
      () async {
        when(() => tokenStorage.readToken()).thenAnswer(
          (_) async => StoredAuthToken(
            accessToken: 'tok',
            expiresAt: fixedNow.add(const Duration(hours: 1)),
          ),
        );
        when(() => authRepository.currentUser()).thenAnswer(
          (_) async => const AppFailure(
            AppException(
              code: AppErrorCode.serviceUnavailable,
              message: 'unavailable',
            ),
          ),
        );

        await buildSut().restore();

        expect(appSession.isAuthenticated, isFalse);
        verifyNever(() => tokenStorage.clear());
      },
    );
  });
}
