import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/auth_providers.dart';
import 'package:inventory_mobile/domain/repositories/auth_repository.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/ui/home/home_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/test_theme.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

GoRouter _buildAuthAwareRouter(AppSession session) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: session,
    redirect: (context, state) {
      final isPublic = state.matchedLocation == '/login';
      if (!session.isAuthenticated && !isPublic) {
        return '/login';
      }
      if (session.isAuthenticated && isPublic) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/login',
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('LOGIN_STUB'))),
      ),
    ],
  );
}

Widget _harness({
  required _MockAuthRepository repository,
  required AppSession session,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      appSessionProvider.overrideWithValue(session),
    ],
    child: MaterialApp.router(
      theme: buildTestTheme(),
      routerConfig: _buildAuthAwareRouter(session),
    ),
  );
}

void main() {
  late _MockAuthRepository repository;
  late AppSession session;

  setUp(() {
    repository = _MockAuthRepository();
    session = AppSession()..signInAsDemoAdmin();
  });

  testWidgets(
    'shows the "Cerrar sesión" action with a logout icon when authenticated',
    (tester) async {
      await tester.pumpWidget(
        _harness(repository: repository, session: session),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Cerrar sesión'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    },
  );

  testWidgets(
    'tapping "Cerrar sesión" calls AuthRepository.logout, signs out the '
    'AppSession and the router redirects to /login',
    (tester) async {
      when(
        () => repository.logout(),
      ).thenAnswer((_) async => const AppSuccess<void>(null));

      await tester.pumpWidget(
        _harness(repository: repository, session: session),
      );
      await tester.pumpAndSettle();

      expect(session.isAuthenticated, isTrue);

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pumpAndSettle();

      verify(() => repository.logout()).called(1);
      expect(session.isAuthenticated, isFalse);
      expect(session.user, isNull);
      expect(find.text('LOGIN_STUB'), findsOneWidget);
    },
  );

  testWidgets(
    'duplicate taps while logout is loading do not trigger duplicate logout '
    'calls',
    (tester) async {
      final pending = Completer<AppResult<void>>();
      when(() => repository.logout()).thenAnswer((_) => pending.future);

      await tester.pumpWidget(
        _harness(repository: repository, session: session),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pump();

      verify(() => repository.logout()).called(1);

      pending.complete(const AppSuccess<void>(null));
      await tester.pumpAndSettle();
    },
  );
}
