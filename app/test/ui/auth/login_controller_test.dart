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
import 'package:inventory_mobile/ui/auth/login_controller.dart';
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

  setUpAll(() {
    registerFallbackValue(_adminUser());
  });

  setUp(() {
    repository = _MockAuthRepository();
    session = AppSession();
  });

  test('initial state is not loading and has no error message', () {
    final container = _container(repository: repository, session: session);

    final state = container.read(loginControllerProvider);

    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
  });

  test(
    'submit success trims the email, calls the repository once and '
    'authenticates the AppSession',
    () async {
      final user = _adminUser();
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AppSuccess(user));

      final container = _container(repository: repository, session: session);
      final controller = container.read(loginControllerProvider.notifier);

      await controller.submit(
        email: '  user@example.com  ',
        password: 'password123',
      );

      verify(
        () => repository.login(
          email: 'user@example.com',
          password: 'password123',
        ),
      ).called(1);

      expect(session.user, same(user));
      expect(session.isAuthenticated, isTrue);

      final finalState = container.read(loginControllerProvider);
      expect(finalState.isLoading, isFalse);
      expect(finalState.errorMessage, isNull);
    },
  );

  test('submit toggles isLoading while the repository call is pending',
      () async {
    final pending = Completer<AppResult<AppUser>>();
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => pending.future);

    final container = _container(repository: repository, session: session);
    final controller = container.read(loginControllerProvider.notifier);

    final future = controller.submit(
      email: 'user@example.com',
      password: 'password123',
    );

    expect(container.read(loginControllerProvider).isLoading, isTrue);

    pending.complete(AppSuccess(_adminUser()));
    await future;

    expect(container.read(loginControllerProvider).isLoading, isFalse);
  });

  test('duplicate submit while loading does not call the repository twice',
      () async {
    final pending = Completer<AppResult<AppUser>>();
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => pending.future);

    final container = _container(repository: repository, session: session);
    final controller = container.read(loginControllerProvider.notifier);

    final first = controller.submit(
      email: 'user@example.com',
      password: 'password123',
    );
    final second = controller.submit(
      email: 'user@example.com',
      password: 'password123',
    );

    verify(
      () => repository.login(
        email: 'user@example.com',
        password: 'password123',
      ),
    ).called(1);

    pending.complete(AppSuccess(_adminUser()));
    await Future.wait([first, second]);
  });

  test('AppFailure unauthorized maps to the Spanish credentials message',
      () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AppFailure(
        AppException(code: AppErrorCode.unauthorized, message: 'bad creds'),
      ),
    );

    final container = _container(repository: repository, session: session);
    final controller = container.read(loginControllerProvider.notifier);

    await controller.submit(
      email: 'user@example.com',
      password: 'wrong-password',
    );

    final state = container.read(loginControllerProvider);
    expect(state.errorMessage, 'Correo o contraseña incorrectos.');
    expect(state.isLoading, isFalse);
    expect(session.isAuthenticated, isFalse);
  });

  test('AppFailure networkError maps to the Spanish no-connection message',
      () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AppFailure(
        AppException(code: AppErrorCode.networkError, message: 'no network'),
      ),
    );

    final container = _container(repository: repository, session: session);
    final controller = container.read(loginControllerProvider.notifier);

    await controller.submit(
      email: 'user@example.com',
      password: 'password123',
    );

    expect(
      container.read(loginControllerProvider).errorMessage,
      'Sin conexión. Inténtalo de nuevo.',
    );
    expect(session.isAuthenticated, isFalse);
  });

  test('AppFailure timeout maps to the Spanish timeout message', () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AppFailure(
        AppException(code: AppErrorCode.timeout, message: 'slow'),
      ),
    );

    final container = _container(repository: repository, session: session);
    final controller = container.read(loginControllerProvider.notifier);

    await controller.submit(
      email: 'user@example.com',
      password: 'password123',
    );

    expect(
      container.read(loginControllerProvider).errorMessage,
      'La solicitud tardó demasiado. Inténtalo de nuevo.',
    );
  });

  test(
    'AppFailure serviceUnavailable maps to the Spanish unavailable message',
    () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AppFailure(
          AppException(
            code: AppErrorCode.serviceUnavailable,
            message: 'down',
          ),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(loginControllerProvider.notifier);

      await controller.submit(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(
        container.read(loginControllerProvider).errorMessage,
        'El servidor no está disponible.',
      );
    },
  );

  test('AppFailure with an unknown code maps to the generic Spanish message',
      () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AppFailure(
        AppException(code: AppErrorCode.unexpected, message: 'boom'),
      ),
    );

    final container = _container(repository: repository, session: session);
    final controller = container.read(loginControllerProvider.notifier);

    await controller.submit(
      email: 'user@example.com',
      password: 'password123',
    );

    expect(
      container.read(loginControllerProvider).errorMessage,
      'No pudimos iniciar sesión. Inténtalo de nuevo.',
    );
  });
}
