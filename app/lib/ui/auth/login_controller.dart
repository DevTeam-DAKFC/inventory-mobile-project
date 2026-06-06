import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../data/providers/auth_providers.dart';
import '../../navigation/app_session.dart';

class LoginState extends Equatable {
  const LoginState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  LoginState copyWith({bool? isLoading, Object? errorMessage = _unset}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  static const Object _unset = Object();

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) {
      return;
    }

    state = const LoginState(isLoading: true);

    final trimmedEmail = email.trim();
    final result = await ref
        .read(authRepositoryProvider)
        .login(email: trimmedEmail, password: password);

    final user = result.dataOrNull;
    if (user != null) {
      ref.read(appSessionProvider).setAuthenticatedUser(user);
      state = const LoginState();
      return;
    }

    state = LoginState(errorMessage: _messageFor(result.exceptionOrNull));
  }

  String _messageFor(AppException? exception) {
    switch (exception?.code) {
      case AppErrorCode.unauthorized:
        return 'Acceso inválido. Por favor, inténtelo otra vez.';
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
}

final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginState>(
  LoginController.new,
);
