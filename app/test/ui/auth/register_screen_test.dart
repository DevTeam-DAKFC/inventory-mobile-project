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
import 'package:inventory_mobile/ui/auth/register_screen.dart';
import 'package:inventory_mobile/ui/auth/widgets/auth_primary_button.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

AppUser _collaboratorUser() => AppUser(
  id: 'collab_1',
  name: 'Andrés Soto',
  email: 'andres.soto@inventario-demo.com',
  role: UserRole.collaborator,
  branchIds: const ['branch_central'],
  isActive: true,
  createdAt: DateTime.utc(2026, 6, 5, 12),
);

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Center(child: Text('LOGIN_STUB'))),
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
    initialLocation: '/register',
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
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Center(child: Text('LOGIN_STUB'))),
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

Future<void> _tapPrimary(WidgetTester tester) async {
  final button = find.byType(AuthPrimaryButton);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
}

Finder _richTextPlain(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.textSpan?.toPlainText() == text,
    description: 'Text.rich with plain text "$text"',
  );
}

Finder _textData(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == text,
    description: 'Text widget with data "$text"',
  );
}

void main() {
  late _MockAuthRepository repository;
  late AppSession session;

  setUp(() {
    repository = _MockAuthRepository();
    session = AppSession();
  });

  testWidgets('renders Spanish inventory-focused copy and the primary CTA', (tester) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    expect(find.text('Inventario'), findsOneWidget);
    expect(_richTextPlain('Crear cuenta'), findsOneWidget);
    expect(
      find.text('Registrá tu acceso para gestionar productos y movimientos entre sucursales.'),
      findsOneWidget,
    );
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(_textData('Crear cuenta'), findsOneWidget);
    expect(find.text('¿Ya tienes cuenta?'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('empty submit shows three required-field errors and does not call register', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await _tapPrimary(tester);
    await tester.pump();

    expect(find.text('El nombre es obligatorio.'), findsOneWidget);
    expect(find.text('El correo electrónico es obligatorio.'), findsOneWidget);
    expect(find.text('La contraseña es obligatoria.'), findsOneWidget);
    verifyNever(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('invalid email shows Spanish email error and does not call register', (tester) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Andrés Soto');
    await tester.enterText(find.byType(TextFormField).at(1), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await _tapPrimary(tester);
    await tester.pump();

    expect(find.text('Ingresa un correo electrónico válido.'), findsOneWidget);
    verifyNever(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('short password shows Spanish password error and does not call register', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Andrés Soto');
    await tester.enterText(find.byType(TextFormField).at(1), 'andres@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '1234567');
    await _tapPrimary(tester);
    await tester.pump();

    expect(find.text('La contraseña debe tener al menos 8 caracteres.'), findsOneWidget);
    verifyNever(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('valid submit calls register with trimmed name and email', (tester) async {
    when(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AppSuccess(_collaboratorUser()));

    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '  Andrés Soto  ');
    await tester.enterText(find.byType(TextFormField).at(1), '  andres@example.com  ');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await _tapPrimary(tester);
    await tester.pumpAndSettle();

    verify(
      () => repository.register(
        name: 'Andrés Soto',
        email: 'andres@example.com',
        password: 'password123',
      ),
    ).called(1);
  });

  testWidgets('loading state shows spinner and prevents duplicate submits', (tester) async {
    final pending = Completer<AppResult<AppUser>>();
    when(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => pending.future);

    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Andrés Soto');
    await tester.enterText(find.byType(TextFormField).at(1), 'andres@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await _tapPrimary(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pump();
    verify(
      () => repository.register(
        name: 'Andrés Soto',
        email: 'andres@example.com',
        password: 'password123',
      ),
    ).called(1);

    pending.complete(AppSuccess(_collaboratorUser()));
    await tester.pumpAndSettle();
  });

  testWidgets('AppSuccess authenticates the AppSession and routes to /home', (tester) async {
    final user = _collaboratorUser();
    when(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => AppSuccess(user));

    await tester.pumpWidget(
      _harness(repository: repository, session: session, router: _buildAuthAwareRouter(session)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Andrés Soto');
    await tester.enterText(find.byType(TextFormField).at(1), 'andres@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await _tapPrimary(tester);
    await tester.pumpAndSettle();

    expect(session.user, same(user));
    expect(session.isAuthenticated, isTrue);
    expect(find.text('HOME_STUB'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsNothing);
  });

  testWidgets('AppFailure conflict shows the Spanish duplicate-email banner', (tester) async {
    when(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async =>
          const AppFailure(AppException(code: AppErrorCode.conflict, message: 'duplicate email')),
    );

    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Andrés Soto');
    await tester.enterText(find.byType(TextFormField).at(1), 'andres@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await _tapPrimary(tester);
    await tester.pumpAndSettle();

    expect(find.text('Ese correo ya está registrado.'), findsOneWidget);
    expect(session.isAuthenticated, isFalse);
  });

  testWidgets('AppFailure networkError shows the Spanish no-connection banner', (tester) async {
    when(
      () => repository.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async =>
          const AppFailure(AppException(code: AppErrorCode.networkError, message: 'no network')),
    );

    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Andrés Soto');
    await tester.enterText(find.byType(TextFormField).at(1), 'andres@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await _tapPrimary(tester);
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión. Inténtalo de nuevo.'), findsOneWidget);
  });

  testWidgets('tapping "Iniciar sesión" navigates back to /login', (tester) async {
    await tester.pumpWidget(_harness(repository: repository, session: session));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_STUB'), findsOneWidget);
  });
}
