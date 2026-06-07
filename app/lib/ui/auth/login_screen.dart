import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/validation/auth_validators.dart';
import '../../navigation/routes.dart';
import 'login_controller.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_form_field.dart';
import 'widgets/auth_package_mark.dart';
import 'widgets/auth_primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    await ref
        .read(loginControllerProvider.notifier)
        .submit(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final isLoading = state.isLoading;
    final errorMessage = state.errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFF06090B),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _IdentityRow(),
                          const SizedBox(height: 22),
                          const _Headline(),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingresá para gestionar inventario entre sucursales.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFA9B4BE),
                              fontSize: 14,
                              height: 1.5,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _AuthSheet(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
                                  autofillHints: const [AutofillHints.password],
                                ),
                                if (errorMessage != null) ...[
                                  const SizedBox(height: 14),
                                  AuthErrorBanner(message: errorMessage),
                                ],
                                const SizedBox(height: 18),
                                AuthPrimaryButton(
                                  label: 'Iniciar sesión',
                                  isLoading: isLoading,
                                  onPressed: isLoading ? null : _onSubmit,
                                ),
                                const SizedBox(height: 14),
                                _RegisterPrompt(
                                  enabled: !isLoading,
                                  onTap: () => context.go(AppRoutes.register),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        AuthPackageMark(size: 48),
        SizedBox(width: 10),
        Text(
          'Inventario',
          style: TextStyle(
            color: Color(0xFFA9B4BE),
            fontSize: 14,
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
    return const FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Inicio de ',
              style: TextStyle(color: Color(0xFFF8FAFC)),
            ),
            TextSpan(
              text: 'sesión',
              style: TextStyle(color: Color(0xFF14B8A6)),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 1.12,
          letterSpacing: -0.6,
        ),
      ),
    );
  }
}

class _AuthSheet extends StatelessWidget {
  const _AuthSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1418),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x12FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.enabled, required this.onTap});

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
            '¿No tienes cuenta?',
            style: TextStyle(
              color: Color(0xFFA9B4BE),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'Crear cuenta',
              style: TextStyle(
                color: enabled
                    ? const Color(0xFF14B8A6)
                    : const Color(0xFF6F7C86),
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
