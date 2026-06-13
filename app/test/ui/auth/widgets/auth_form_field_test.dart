import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/ui/auth/widgets/auth_form_field.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  testWidgets('renders label and hint text', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      _host(
        AuthFormField(
          label: 'Correo electrónico',
          hintText: 'tu@email.com',
          controller: controller,
        ),
      ),
    );

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('tu@email.com'), findsOneWidget);
  });

  testWidgets('shows visible text when obscureText is false', (tester) async {
    final controller = TextEditingController(text: 'visible-text');

    await tester.pumpWidget(
      _host(AuthFormField(label: 'Correo electrónico', controller: controller)),
    );

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isFalse);
  });

  testWidgets('obscures text when obscureText is true', (tester) async {
    final controller = TextEditingController(text: 'super-secret');

    await tester.pumpWidget(
      _host(
        AuthFormField(
          label: 'Contraseña',
          controller: controller,
          obscureText: true,
        ),
      ),
    );

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
  });

  testWidgets('runs validator when the host Form is validated', (tester) async {
    final controller = TextEditingController(text: '');
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      _host(
        Form(
          key: formKey,
          child: AuthFormField(
            label: 'Correo electrónico',
            controller: controller,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'required' : null,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('required'), findsOneWidget);
  });
}
