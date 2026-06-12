import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/app/app.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/stock_providers.dart';
import 'package:inventory_mobile/domain/models/stock_overview_item.dart';
import 'package:inventory_mobile/domain/repositories/stock_repository.dart';
import 'package:inventory_mobile/navigation/app_router.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/navigation/routes.dart';
import 'package:inventory_mobile/navigation/session_restore_controller.dart';

import 'support/test_theme.dart';

void main() {
  testWidgets('shows login as the public entry point', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionRestoreProvider.overrideWith((ref) async {})],
        child: const InventoryMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(_richTextPlain('Inicio de sesión'), findsOneWidget);
  });

  testWidgets('redirects unauthenticated users away from private routes', (
    tester,
  ) async {
    final session = AppSession();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Resumen de inventario'), findsNothing);
  });

  testWidgets('authenticated users reach the main app shell', (tester) async {
    final session = AppSession()..signInAsDemoAdmin();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resumen de inventario'), findsOneWidget);
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
    expect(find.text('Productos'), findsWidgets);
    expect(find.text('Buscar por nombre, SKU o código...'), findsOneWidget);

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
    expect(session.role, SessionRole.collaborator);
    expect(session.canViewAdminEntries, isFalse);
  });

  testWidgets('authenticated admin can reach CSV import flow', (tester) async {
    final session = AppSession()..signInAsDemoAdmin();

    await tester.pumpWidget(
      _RouterTestApp(
        session: session,
        initialLocation: AppRoutes.productImport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Importar productos'), findsOneWidget);
    expect(find.text('Seleccionar archivo'), findsOneWidget);
    expect(find.text('Formato esperado'), findsOneWidget);
  });

  testWidgets('logout returns the user to the public auth flow', (
    tester,
  ) async {
    final session = AppSession()..signInAsDemoAdmin();

    await tester.pumpWidget(
      _RouterTestApp(session: session, initialLocation: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    session.signOut();
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}

Finder _navigationDestination(String label) {
  return find.text(label);
}

Finder _richTextPlain(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.textSpan?.toPlainText() == text,
    description: 'Text.rich with plain text "$text"',
  );
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.session, required this.initialLocation});

  final AppSession session;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appSessionProvider.overrideWithValue(session),
        stockRepositoryProvider.overrideWithValue(_FakeStockRepository()),
      ],
      child: MaterialApp.router(
        theme: buildTestTheme(),
        routerConfig: buildAppRouter(session, initialLocation: initialLocation),
      ),
    );
  }
}

final class _FakeStockRepository implements StockRepository {
  @override
  Future<AppResult<List<StockOverviewItem>>> getStockByBranch(
    String branchId,
  ) async {
    return const AppSuccess([]);
  }
}
