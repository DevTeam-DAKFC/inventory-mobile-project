import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/auth_providers.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';
import 'package:inventory_mobile/domain/repositories/auth_repository.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/ui/auth/logout_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

AppUser _adminUser() => AppUser(
  id: 'admin_1',
  name: 'María Rodríguez',
  email: 'admin@inventario-demo.com',
  role: UserRole.admin,
  branchIds: const ['branch_central'],
  isActive: true,
  createdAt: DateTime.utc(2026, 6, 2, 20),
);

ProviderContainer _container({
  required _MockAuthRepository repository,
  required AppSession session,
}) {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      appSessionProvider.overrideWithValue(session),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late _MockAuthRepository repository;
  late AppSession session;

  setUp(() {
    repository = _MockAuthRepository();
    session = AppSession()..setAuthenticatedUser(_adminUser());
  });

  test('initial state is not loading and has no error message', () {
    final container = _container(repository: repository, session: session);

    final state = container.read(logoutControllerProvider);

    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
  });

  test(
    'successful logout calls AuthRepository.logout exactly once, signs out '
    'the AppSession and resets controller state',
    () async {
      when(() => repository.logout())
          .thenAnswer((_) async => const AppSuccess<void>(null));

      final container = _container(repository: repository, session: session);
      final controller = container.read(logoutControllerProvider.notifier);

      expect(session.isAuthenticated, isTrue);

      await controller.logout();

      verify(() => repository.logout()).called(1);
      expect(session.isAuthenticated, isFalse);
      expect(session.user, isNull);

      final state = container.read(logoutControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    },
  );

  test('logout toggles isLoading while the repository future is pending',
      () async {
    final pending = Completer<AppResult<void>>();
    when(() => repository.logout()).thenAnswer((_) => pending.future);

    final container = _container(repository: repository, session: session);
    final controller = container.read(logoutControllerProvider.notifier);

    final future = controller.logout();

    expect(container.read(logoutControllerProvider).isLoading, isTrue);

    pending.complete(const AppSuccess<void>(null));
    await future;

    expect(container.read(logoutControllerProvider).isLoading, isFalse);
  });

  test('duplicate logout while loading does not call the repository twice',
      () async {
    final pending = Completer<AppResult<void>>();
    when(() => repository.logout()).thenAnswer((_) => pending.future);

    final container = _container(repository: repository, session: session);
    final controller = container.read(logoutControllerProvider.notifier);

    final first = controller.logout();
    final second = controller.logout();

    verify(() => repository.logout()).called(1);

    pending.complete(const AppSuccess<void>(null));
    await Future.wait([first, second]);
  });

  test(
    'AppFailure(networkError) still signs out locally and clears state',
    () async {
      when(() => repository.logout()).thenAnswer(
        (_) async => const AppFailure<void>(
          AppException(code: AppErrorCode.networkError, message: 'no network'),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(logoutControllerProvider.notifier);

      await controller.logout();

      expect(session.isAuthenticated, isFalse);
      final state = container.read(logoutControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    },
  );

  test(
    'AppFailure(timeout) still signs out locally and clears state',
    () async {
      when(() => repository.logout()).thenAnswer(
        (_) async => const AppFailure<void>(
          AppException(code: AppErrorCode.timeout, message: 'slow'),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(logoutControllerProvider.notifier);

      await controller.logout();

      expect(session.isAuthenticated, isFalse);
      final state = container.read(logoutControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    },
  );

  test(
    'AppFailure(serviceUnavailable) still signs out locally and clears state',
    () async {
      when(() => repository.logout()).thenAnswer(
        (_) async => const AppFailure<void>(
          AppException(
            code: AppErrorCode.serviceUnavailable,
            message: 'down',
          ),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(logoutControllerProvider.notifier);

      await controller.logout();

      expect(session.isAuthenticated, isFalse);
      final state = container.read(logoutControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    },
  );

  test(
    'AppFailure(unexpected) still signs out locally and clears state',
    () async {
      when(() => repository.logout()).thenAnswer(
        (_) async => const AppFailure<void>(
          AppException(code: AppErrorCode.unexpected, message: 'boom'),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(logoutControllerProvider.notifier);

      await controller.logout();

      expect(session.isAuthenticated, isFalse);
      final state = container.read(logoutControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    },
  );

  test(
    'a truly unexpected thrown exception still signs out locally and surfaces '
    'a Spanish error message',
    () async {
      when(() => repository.logout()).thenThrow(Exception('catastrophic'));

      final container = _container(repository: repository, session: session);
      final controller = container.read(logoutControllerProvider.notifier);

      expect(session.isAuthenticated, isTrue);

      await controller.logout();

      expect(session.isAuthenticated, isFalse);
      final state = container.read(logoutControllerProvider);
      expect(state.isLoading, isFalse);
      expect(
        state.errorMessage,
        'No pudimos cerrar sesión completamente. Inténtalo de nuevo.',
      );
    },
  );
}
