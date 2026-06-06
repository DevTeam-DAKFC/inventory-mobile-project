import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../../navigation/app_session.dart';

class LogoutState extends Equatable {
  const LogoutState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class LogoutController extends Notifier<LogoutState> {
  @override
  LogoutState build() => const LogoutState();

  Future<void> logout() async {
    if (state.isLoading) {
      return;
    }

    state = const LogoutState(isLoading: true);

    try {
      await ref.read(authRepositoryProvider).logout();
      ref.read(appSessionProvider).signOut();
      state = const LogoutState();
    } catch (_) {
      try {
        ref.read(appSessionProvider).signOut();
      } catch (_) {}
      state = const LogoutState(
        errorMessage:
            'No pudimos cerrar sesión completamente. Inténtalo de nuevo.',
      );
    }
  }
}

final logoutControllerProvider =
    NotifierProvider<LogoutController, LogoutState>(LogoutController.new);
