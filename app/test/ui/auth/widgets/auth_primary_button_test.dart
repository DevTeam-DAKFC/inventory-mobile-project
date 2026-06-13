import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/ui/auth/widgets/auth_primary_button.dart';

import '../../../support/test_theme.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: buildTestTheme(),
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(
      _host(AuthPrimaryButton(label: 'Iniciar sesión', onPressed: () {})),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      _host(
        AuthPrimaryButton(label: 'Iniciar sesión', onPressed: () => taps++),
      ),
    );

    await tester.tap(find.byType(AuthPrimaryButton));
    expect(taps, 1);
  });

  testWidgets(
    'shows a CircularProgressIndicator and disables tap when isLoading',
    (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _host(
          AuthPrimaryButton(
            label: 'Iniciar sesión',
            onPressed: () => taps++,
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);

      await tester.tap(find.byType(AuthPrimaryButton));
      expect(taps, 0);
    },
  );

  testWidgets('null onPressed disables tap even when not loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const AuthPrimaryButton(label: 'Iniciar sesión', onPressed: null)),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pump();
  });
}
