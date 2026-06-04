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
    expect(find.text('Inventory overview'), findsNothing);
  });

  testWidgets('authenticated users reach the main app shell', (tester) async {
    final session = AppSession()..signInAsDemoAdmin();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inventory overview'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(_navigationDestination('Products'), findsOneWidget);
    expect(_navigationDestination('Stock'), findsOneWidget);
    expect(_navigationDestination('History'), findsOneWidget);
  });

  testWidgets('navigates between core shell screens', (tester) async {
    final session = AppSession()..signInAsDemoAdmin();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    await tester.tap(_navigationDestination('Products'));
    await tester.pumpAndSettle();
    expect(
      find.text('This screen is ready for its feature implementation.'),
      findsOneWidget,
    );

    await tester.tap(_navigationDestination('Stock'));
    await tester.pumpAndSettle();
    expect(find.text('Stock'), findsWidgets);

    await tester.tap(_navigationDestination('History'));
    await tester.pumpAndSettle();
    expect(find.text('History'), findsWidgets);
  });

  testWidgets('hides admin navigation entries for collaborators', (
    tester,
  ) async {
    final session = AppSession()..signInAsDemoCollaborator();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    expect(find.text('Import products'), findsNothing);
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
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(NavigationDestination),
  );
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
