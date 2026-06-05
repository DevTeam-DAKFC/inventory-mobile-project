import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/ui/auth/widgets/auth_error_banner.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  testWidgets('renders the message when non-empty', (tester) async {
    await tester.pumpWidget(
      _host(const AuthErrorBanner(message: 'Correo o contraseña incorrectos.')),
    );

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('renders nothing for a null message', (tester) async {
    await tester.pumpWidget(_host(const AuthErrorBanner(message: null)));

    expect(find.byType(Container), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('renders nothing for an empty message', (tester) async {
    await tester.pumpWidget(_host(const AuthErrorBanner(message: '')));

    expect(find.byType(Container), findsNothing);
    expect(find.byType(Text), findsNothing);
  });
}
