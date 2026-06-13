import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/notification_providers.dart';
import '../../navigation/app_session.dart';

class RegisterState extends Equatable {
  const RegisterState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  Future<void> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isLoading) {
      return;
    }

    state = const RegisterState(isLoading: true);

    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    final repository = ref.read(authRepositoryProvider);
    final appSession = ref.read(appSessionProvider);
    final result = await repository.register(
      name: trimmedName,
      email: trimmedEmail,
      password: password,
    );

    final user = result.dataOrNull;
    if (user != null) {
      appSession.setAuthenticatedUser(user);
      try {
        await ref
            .read(notificationSessionCoordinatorProvider)
            .onAuthenticated(user.id);
      } catch (_) {}
      if (ref.mounted) state = const RegisterState();
      return;
    }

    if (ref.mounted) {
      state = RegisterState(errorMessage: _messageFor(result.exceptionOrNull));
    }
  }

  String _messageFor(AppException? exception) {
    switch (exception?.code) {
      case AppErrorCode.unauthorized:
        return 'No pudimos validar tus credenciales.';
      case AppErrorCode.validationError:
        return 'Revisa los campos ingresados.';
      case AppErrorCode.conflict:
        return 'Ese correo ya está registrado.';
      case AppErrorCode.networkError:
        return 'Sin conexión. Inténtalo de nuevo.';
      case AppErrorCode.timeout:
        return 'La solicitud tardó demasiado. Inténtalo de nuevo.';
      case AppErrorCode.serviceUnavailable:
        return 'El servidor no está disponible.';
      default:
        return 'No pudimos crear la cuenta. Inténtalo de nuevo.';
    }
  }
}

final registerControllerProvider =
    NotifierProvider.autoDispose<RegisterController, RegisterState>(
      RegisterController.new,
    );
