import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/validation/auth_validators.dart';
import '../../data/providers/auth_providers.dart';
import '../../navigation/app_session.dart';
import '../../navigation/routes.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_form_field.dart';
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

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage = result.isSuccess
          ? null
          : _messageFor(result.exceptionOrNull);
    });

    final user = result.dataOrNull;
    if (user != null) {
      // Router redirect listens to AppSession and will navigate to /home.
      ref.read(appSessionProvider).setAuthenticatedUser(user);
    }
  }

  String _messageFor(AppException? exception) {
    switch (exception?.code) {
      case AppErrorCode.unauthorized:
        return 'Correo o contraseña incorrectos.';
      case AppErrorCode.validationError:
        return 'Revisa los campos ingresados.';
      case AppErrorCode.networkError:
        return 'Sin conexión. Inténtalo de nuevo.';
      case AppErrorCode.timeout:
        return 'La solicitud tardó demasiado. Inténtalo de nuevo.';
      case AppErrorCode.serviceUnavailable:
        return 'El servidor no está disponible.';
      default:
        return 'No pudimos iniciar sesión. Inténtalo de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0D0F), Color(0xFF111A20)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 384),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _LogoTile(),
                      const SizedBox(height: 16),
                      const Text(
                        'Control de inventario',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gestiona productos, stock y movimientos por sucursal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFA9B4BE),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AuthFormField(
                        label: 'Correo electrónico',
                        hintText: 'tu@email.com',
                        controller: _emailController,
                        validator: AuthValidators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      AuthFormField(
                        label: 'Contraseña',
                        hintText: '••••••••',
                        controller: _passwordController,
                        validator: AuthValidators.validatePassword,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        onFieldSubmitted: (_) => _submit(),
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: 16),
                      AuthErrorBanner(message: _errorMessage),
                      if (_errorMessage != null) const SizedBox(height: 16),
                      AuthPrimaryButton(
                        label: 'Iniciar sesión',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => context.go(AppRoutes.register),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF14B8A6),
                        ),
                        child: const Text('Crear cuenta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF182126),
          border: Border.all(color: const Color(0x0FFFFFFF)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.inventory_2_outlined,
          size: 32,
          color: Color(0xFF14B8A6),
        ),
      ),
    );
  }
}
