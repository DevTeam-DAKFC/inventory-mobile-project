import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/auth_providers.dart';
import 'package:inventory_mobile/data/providers/notification_providers.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';
import 'package:inventory_mobile/domain/repositories/auth_repository.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/notifications/notification_session_coordinator.dart';
import 'package:inventory_mobile/ui/auth/register_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeNotificationSessionCoordinator
    implements NotificationSessionCoordinator {
  final List<String> authenticatedUserIds = [];

  @override
  Future<void> beforeLogout() async {}

  @override
  Future<void> onAuthenticated(String userId) async {
    authenticatedUserIds.add(userId);
  }
}

AppUser _collaboratorUser() => AppUser(
  id: 'collab_1',
  name: 'Andrés Soto',
  email: 'andres.soto@inventario-demo.com',
  role: UserRole.collaborator,
  branchIds: const ['branch_central'],
  isActive: true,
  createdAt: DateTime.utc(2026, 6, 5, 12),
);

ProviderContainer _container({
  required _MockAuthRepository repository,
  required AppSession session,
  _FakeNotificationSessionCoordinator? notifications,
}) {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      appSessionProvider.overrideWithValue(session),
      notificationSessionCoordinatorProvider.overrideWithValue(
        notifications ?? _FakeNotificationSessionCoordinator(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late _MockAuthRepository repository;
  late AppSession session;

  setUpAll(() {
    registerFallbackValue(_collaboratorUser());
  });

  setUp(() {
    repository = _MockAuthRepository();
    session = AppSession();
  });

  test('initial state is not loading and has no error message', () {
    final container = _container(repository: repository, session: session);

    final state = container.read(registerControllerProvider);

    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
  });

  test('submit success trims name and email, calls the repository exactly once '
      'and authenticates the AppSession', () async {
    final user = _collaboratorUser();
    final notifications = _FakeNotificationSessionCoordinator();
    when(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AppSuccess(user));

    final container = _container(
      repository: repository,
      session: session,
      notifications: notifications,
    );
    final controller = container.read(registerControllerProvider.notifier);

    await controller.submit(
      name: '  Andrés Soto  ',
      email: '  andres.soto@inventario-demo.com  ',
      password: 'password123',
    );

    verify(
      () => repository.register(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      ),
    ).called(1);

    expect(session.user, same(user));
    expect(session.isAuthenticated, isTrue);
    expect(notifications.authenticatedUserIds, ['collab_1']);

    final finalState = container.read(registerControllerProvider);
    expect(finalState.isLoading, isFalse);
    expect(finalState.errorMessage, isNull);
  });

  test(
    'submit toggles isLoading while the repository future is pending',
    () async {
      final pending = Completer<AppResult<AppUser>>();
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => pending.future);

      final container = _container(repository: repository, session: session);
      final controller = container.read(registerControllerProvider.notifier);

      final future = controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );

      expect(container.read(registerControllerProvider).isLoading, isTrue);

      pending.complete(AppSuccess(_collaboratorUser()));
      await future;

      expect(container.read(registerControllerProvider).isLoading, isFalse);
    },
  );

  test(
    'duplicate submit while loading does not call the repository twice',
    () async {
      final pending = Completer<AppResult<AppUser>>();
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => pending.future);

      final container = _container(repository: repository, session: session);
      final controller = container.read(registerControllerProvider.notifier);

      final first = controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );
      final second = controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );

      verify(
        () => repository.register(
          name: 'Andrés Soto',
          email: 'andres.soto@inventario-demo.com',
          password: 'password123',
        ),
      ).called(1);

      pending.complete(AppSuccess(_collaboratorUser()));
      await Future.wait([first, second]);
    },
  );

  test(
    'AppFailure unauthorized maps to the Spanish credentials message',
    () async {
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AppFailure(
          AppException(code: AppErrorCode.unauthorized, message: 'rejected'),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(registerControllerProvider.notifier);

      await controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );

      final state = container.read(registerControllerProvider);
      expect(state.errorMessage, 'No pudimos validar tus credenciales.');
      expect(state.isLoading, isFalse);
      expect(session.isAuthenticated, isFalse);
    },
  );

  test(
    'AppFailure validationError maps to the Spanish field-review message',
    () async {
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AppFailure(
          AppException(
            code: AppErrorCode.validationError,
            message: 'bad fields',
          ),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(registerControllerProvider.notifier);

      await controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );

      expect(
        container.read(registerControllerProvider).errorMessage,
        'Revisa los campos ingresados.',
      );
    },
  );

  test(
    'AppFailure conflict maps to the Spanish duplicate-email message',
    () async {
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AppFailure(
          AppException(code: AppErrorCode.conflict, message: 'already exists'),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(registerControllerProvider.notifier);

      await controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );

      final state = container.read(registerControllerProvider);
      expect(state.errorMessage, 'Ese correo ya está registrado.');
      expect(session.isAuthenticated, isFalse);
    },
  );

  test(
    'AppFailure networkError maps to the Spanish no-connection message',
    () async {
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AppFailure(
          AppException(code: AppErrorCode.networkError, message: 'no network'),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(registerControllerProvider.notifier);

      await controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );

      expect(
        container.read(registerControllerProvider).errorMessage,
        'Sin conexión. Inténtalo de nuevo.',
      );
      expect(session.isAuthenticated, isFalse);
    },
  );

  test('AppFailure timeout maps to the Spanish timeout message', () async {
    when(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const AppFailure(
        AppException(code: AppErrorCode.timeout, message: 'slow'),
      ),
    );

    final container = _container(repository: repository, session: session);
    final controller = container.read(registerControllerProvider.notifier);

    await controller.submit(
      name: 'Andrés Soto',
      email: 'andres.soto@inventario-demo.com',
      password: 'password123',
    );

    expect(
      container.read(registerControllerProvider).errorMessage,
      'La solicitud tardó demasiado. Inténtalo de nuevo.',
    );
  });

  test(
    'AppFailure serviceUnavailable maps to the Spanish unavailable message',
    () async {
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AppFailure(
          AppException(code: AppErrorCode.serviceUnavailable, message: 'down'),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(registerControllerProvider.notifier);

      await controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );

      expect(
        container.read(registerControllerProvider).errorMessage,
        'El servidor no está disponible.',
      );
    },
  );

  test(
    'AppFailure with an unexpected/default code maps to the generic register '
    'message',
    () async {
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AppFailure(
          AppException(code: AppErrorCode.unexpected, message: 'boom'),
        ),
      );

      final container = _container(repository: repository, session: session);
      final controller = container.read(registerControllerProvider.notifier);

      await controller.submit(
        name: 'Andrés Soto',
        email: 'andres.soto@inventario-demo.com',
        password: 'password123',
      );

      expect(
        container.read(registerControllerProvider).errorMessage,
        'No pudimos crear la cuenta. Inténtalo de nuevo.',
      );
    },
  );
}
