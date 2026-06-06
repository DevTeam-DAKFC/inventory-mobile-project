import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/auth_providers.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';
import 'package:inventory_mobile/domain/repositories/auth_repository.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/ui/auth/login_screen.dart';
import 'package:inventory_mobile/ui/auth/widgets/auth_primary_button.dart';
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

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (_, _) => const Scaffold(body: Center(child: Text('REGISTER_STUB'))),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Center(child: Text('HOME_STUB'))),
      ),
    ],
    refreshListenable: null,
  );
}

GoRouter _buildAuthAwareRouter(AppSession session) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: session,
    redirect: (context, state) {
      final isPublic = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!session.isAuthenticated && !isPublic) {
        return '/login';
      }
      if (session.isAuthenticated && isPublic) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (_, _) => const Scaffold(body: Center(child: Text('REGISTER_STUB'))),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Center(child: Text('HOME_STUB'))),
      ),
    ],
  );
}

Widget _harness({
  required _MockAuthRepository repository,
  required AppSession session,
  GoRouter? router,
}) {
  final r = router ?? _buildRouter();
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      appSessionProvider.overrideWithValue(session),
    ],
    child: MaterialApp.router(routerConfig: r),
  );
}

Finder _richTextPlain(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.textSpan?.toPlainText() == text,
    description: 'Text.rich with plain text "$text"',
  );
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

  testWidgets('renders the auth-shell sign-in copy and the primary CTA', (tester) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();
    expect(find.text('Inventario'), findsOneWidget);
    expect(_richTextPlain('Inicio de sesión'), findsOneWidget);
    expect(find.text('Ingresá para gestionar inventario entre sucursales.'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('¿No tienes cuenta?'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('empty submit shows required-field errors and does not call login', (tester) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pump();

    expect(find.text('El correo electrónico es obligatorio.'), findsOneWidget);
    expect(find.text('La contraseña es obligatoria.'), findsOneWidget);
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('invalid email shows format error', (tester) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pump();

    expect(find.text('Ingresa un correo electrónico válido.'), findsOneWidget);
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('short password shows password validation error', (tester) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), '1234567');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pump();

    expect(find.text('La contraseña debe tener al menos 8 caracteres.'), findsOneWidget);
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('valid submit calls login with trimmed email', (tester) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AppSuccess(_adminUser()));

    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '  user@example.com  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pumpAndSettle();

    verify(() => repository.login(email: 'user@example.com', password: 'password123')).called(1);
  });

  testWidgets('loading state disables the button and shows a spinner', (tester) async {
    final pending = Completer<AppResult<AppUser>>();
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => pending.future);

    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Tapping again must not enqueue a second login call.
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pump();
    verify(() => repository.login(email: 'user@example.com', password: 'password123')).called(1);

    pending.complete(AppSuccess(_adminUser()));
    await tester.pumpAndSettle();
  });

  testWidgets('AppSuccess calls setAuthenticatedUser and the router lands on /home', (
    tester,
  ) async {
    final user = _adminUser();
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AppSuccess(user));

    await tester.pumpWidget(
      _harness(repository: repository, session: session, router: _buildAuthAwareRouter(session)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pumpAndSettle();

    expect(session.user, same(user));
    expect(session.isAuthenticated, isTrue);
    expect(find.text('HOME_STUB'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
  });

  testWidgets('AppFailure unauthorized shows the Spanish credentials banner', (tester) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async =>
          const AppFailure(AppException(code: AppErrorCode.unauthorized, message: 'bad creds')),
    );

    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('Acceso inválido. Por favor, inténtelo otra vez.'), findsOneWidget);
    expect(session.isAuthenticated, isFalse);
  });

  testWidgets('AppFailure networkError shows the Spanish no-connection banner', (tester) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async =>
          const AppFailure(AppException(code: AppErrorCode.networkError, message: 'no network')),
    );

    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión. Inténtalo de nuevo.'), findsOneWidget);
  });

  testWidgets('tapping "Crear cuenta" navigates to /register', (tester) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('REGISTER_STUB'), findsOneWidget);
  });

  testWidgets('after returning to /login from /home, a previous credentials error is '
      'not shown again', (tester) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async =>
          const AppFailure(AppException(code: AppErrorCode.unauthorized, message: 'bad creds')),
    );

    await tester.pumpWidget(
      _harness(repository: repository, session: session, router: _buildAuthAwareRouter(session)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('Acceso inválido. Por favor, inténtelo otra vez.'), findsOneWidget);

    session.setAuthenticatedUser(_adminUser());
    await tester.pumpAndSettle();
    expect(find.text('HOME_STUB'), findsOneWidget);

    session.signOut();
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Acceso inválido. Por favor, inténtelo otra vez.'), findsNothing);
  });
}
