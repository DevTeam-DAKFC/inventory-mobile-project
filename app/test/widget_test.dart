import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/app/app.dart';
import 'package:inventory_mobile/navigation/app_router.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/navigation/routes.dart';

void main() {
  testWidgets('shows login as the public entry point', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: InventoryMobileApp()));

    expect(find.text('Inventory Mobile'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });

  testWidgets('redirects unauthenticated users away from private routes', (
    tester,
  ) async {
    final session = AppSession();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Disponibilidad general'), findsNothing);
  });

  testWidgets('authenticated users reach the main app shell', (tester) async {
    final session = AppSession()..signInAsDemoAdmin();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    expect(find.text('Disponibilidad general'), findsOneWidget);
    expect(_navigationDestination('Inicio'), findsOneWidget);
    expect(_navigationDestination('Productos'), findsOneWidget);
    expect(_navigationDestination('Stock'), findsOneWidget);
    expect(_navigationDestination('Movimientos'), findsOneWidget);
    expect(_navigationDestination('Alertas'), findsOneWidget);
  });

  testWidgets('navigates between core shell screens', (tester) async {
    final session = AppSession()..signInAsDemoAdmin();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    await tester.tap(_navigationDestination('Productos'));
    await tester.pumpAndSettle();
    expect(
      find.text('Reserved for the assigned feature issue.'),
      findsOneWidget,
    );

    await tester.tap(_navigationDestination('Stock'));
    await tester.pumpAndSettle();
    expect(find.text('Stock'), findsWidgets);

    await tester.tap(_navigationDestination('Movimientos'));
    await tester.pumpAndSettle();
    expect(find.text('Movimientos'), findsWidgets);

    await tester.tap(_navigationDestination('Alertas'));
    await tester.pumpAndSettle();
    expect(find.text('Alertas'), findsWidgets);
  });

  testWidgets('shows role state without exposing feature-specific entries', (
    tester,
  ) async {
    final session = AppSession()..signInAsDemoCollaborator();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    expect(find.text('Import products'), findsNothing);
    expect(find.text('collaborator'), findsOneWidget);
  });

  testWidgets('logout returns the user to the public auth flow', (
    tester,
  ) async {
    final session = AppSession()..signInAsDemoAdmin();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}

Finder _navigationDestination(String label) {
  return find.text(label);
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.session, required this.initialLocation});

  final AppSession session;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [appSessionProvider.overrideWithValue(session)],
      child: MaterialApp.router(
        routerConfig: buildAppRouter(session, initialLocation: initialLocation),
      ),
    );
  }
}
