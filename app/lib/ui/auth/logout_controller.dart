import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../../data/providers/notification_providers.dart';
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

    final notifications = ref.read(notificationSessionCoordinatorProvider);
    final repository = ref.read(authRepositoryProvider);
    final appSession = ref.read(appSessionProvider);

    try {
      await notifications.beforeLogout();
    } catch (_) {}

    try {
      await repository.logout();
      appSession.signOut();
      if (ref.mounted) state = const LogoutState();
    } catch (_) {
      try {
        appSession.signOut();
      } catch (_) {}
      if (!ref.mounted) return;
      state = const LogoutState(
        errorMessage:
            'No pudimos cerrar sesión completamente. Inténtalo de nuevo.',
      );
    }
  }
}

final logoutControllerProvider =
    NotifierProvider.autoDispose<LogoutController, LogoutState>(
      LogoutController.new,
    );
