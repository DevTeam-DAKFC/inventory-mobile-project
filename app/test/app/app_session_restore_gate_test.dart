import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/app/app.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';
import 'package:inventory_mobile/navigation/app_session.dart';
import 'package:inventory_mobile/navigation/session_restore_controller.dart';

AppUser _adminUser() => AppUser(
  id: 'admin_1',
  name: 'Test Admin',
  email: 'admin@example.com',
  role: UserRole.admin,
  branchIds: const ['branch_central'],
  isActive: true,
  createdAt: DateTime.utc(2026, 6, 2, 20),
);

void main() {
  testWidgets('shows the restoring screen while sessionRestoreProvider is pending', (tester) async {
    final pending = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionRestoreProvider.overrideWith((ref) => pending.future)],
        child: const InventoryMobileApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Restoring session...'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsNothing);

    // Resolve the pending future so the test exits cleanly.
    pending.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows the login screen once restore completes with no token', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionRestoreProvider.overrideWith((ref) async {})],
        child: const InventoryMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Restoring session...'), findsNothing);
  });

  testWidgets('shows the home content when restore authenticates the session', (tester) async {
    final session = AppSession()..setAuthenticatedUser(_adminUser());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionProvider.overrideWithValue(session),
          sessionRestoreProvider.overrideWith((ref) async {}),
        ],
        child: const InventoryMobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resumen de inventario'), findsOneWidget);
    expect(find.text('Restoring session...'), findsNothing);
    expect(find.text('Sign in to continue'), findsNothing);
  });
}
