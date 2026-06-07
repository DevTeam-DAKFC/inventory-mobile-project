import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_error_code.dart';
import '../core/storage/auth_token_storage.dart';
import '../data/providers/auth_providers.dart';
import '../domain/repositories/auth_repository.dart';
import 'app_session.dart';

class SessionRestoreController {
  SessionRestoreController({
    required this._tokenStorage,
    required this._authRepository,
    required this._appSession,
    this._now = DateTime.now,
  });

  final AuthTokenStorage _tokenStorage;
  final AuthRepository _authRepository;
  final AppSession _appSession;
  final DateTime Function() _now;

  Future<void> restore() async {
    final token = await _tokenStorage.readToken();
    if (token == null) {
      return;
    }
    final nowUtc = _now().toUtc();
    if (!token.expiresAt.toUtc().isAfter(nowUtc)) {
      await _tokenStorage.clear();
      return;
    }

    final result = await _authRepository.currentUser();
    final user = result.dataOrNull;
    if (user != null) {
      _appSession.setAuthenticatedUser(user);
      return;
    }

    final exception = result.exceptionOrNull;
    if (exception?.code == AppErrorCode.unauthorized) {
      await _tokenStorage.clear();
    }
  }
}

final sessionRestoreControllerProvider = Provider<SessionRestoreController>(
  (ref) => SessionRestoreController(
    tokenStorage: ref.watch(tokenStorageProvider),
    authRepository: ref.watch(authRepositoryProvider),
    appSession: ref.watch(appSessionProvider),
  ),
);

final sessionRestoreProvider = FutureProvider<void>((ref) async {
  await ref.watch(sessionRestoreControllerProvider).restore();
});
