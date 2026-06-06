import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/validation/auth_validators.dart';
import '../../navigation/routes.dart';
import 'register_controller.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_form_field.dart';
import 'widgets/auth_package_mark.dart';
import 'widgets/auth_primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    await ref.read(registerControllerProvider.notifier).submit(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFF06090B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandRow(),
                    const SizedBox(height: 32),
                    const _Headline(),
                    const SizedBox(height: 12),
                    const Text(
                      'Registrá tu acceso para gestionar productos y movimientos entre sucursales.',
                      style: TextStyle(
                        color: Color(0xFFA9B4BE),
                        fontSize: 15,
                        height: 1.5,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthFormField(
                      label: 'Nombre',
                      hintText: 'Tu nombre',
                      controller: _nameController,
                      validator: AuthValidators.validateName,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.name],
                    ),
                    const SizedBox(height: 12),
                    AuthFormField(
                      label: 'Correo electrónico',
                      hintText: 'correo@ejemplo.com',
                      controller: _emailController,
                      validator: AuthValidators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 12),
                    AuthFormField(
                      label: 'Contraseña',
                      hintText: '••••••••',
                      controller: _passwordController,
                      validator: AuthValidators.validatePassword,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _onSubmit(),
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      AuthErrorBanner(message: errorMessage),
                    ],
                    const SizedBox(height: 20),
                    AuthPrimaryButton(
                      label: 'Crear cuenta',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _onSubmit,
                    ),
                    const SizedBox(height: 16),
                    _LoginPrompt(
                      enabled: !isLoading,
                      onTap: () => context.go(AppRoutes.login),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        AuthPackageMark(size: 20),
        SizedBox(width: 10),
        Text(
          'Inventario',
          style: TextStyle(
            color: Color(0xFFA9B4BE),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Crear',
          style: TextStyle(
            color: Color(0xFFF8FAFC),
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -0.8,
          ),
        ),
        Text(
          'cuenta',
          style: TextStyle(
            color: Color(0xFF14B8A6),
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '¿Ya tienes cuenta?',
            style: TextStyle(color: Color(0xFFA9B4BE), fontSize: 14, height: 1.4),
          ),
        ),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'Iniciar sesión',
              style: TextStyle(
                color: enabled ? const Color(0xFF14B8A6) : const Color(0xFF6F7C86),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
