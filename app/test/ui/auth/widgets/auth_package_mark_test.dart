import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/ui/auth/widgets/auth_package_mark.dart';

void main() {
  testWidgets('renders a CustomPaint sized to the requested size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AuthPackageMark(size: 48)),
        ),
      ),
    );

    expect(find.byType(AuthPackageMark), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    final renderObject = tester
        .renderObject<RenderBox>(find.byType(AuthPackageMark));
    expect(renderObject.size, const Size(48, 48));
  });

  testWidgets('defaults to a 32px square with teal accent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AuthPackageMark()),
        ),
      ),
    );

    final renderObject = tester
        .renderObject<RenderBox>(find.byType(AuthPackageMark));
    expect(renderObject.size, const Size(32, 32));
  });
}
