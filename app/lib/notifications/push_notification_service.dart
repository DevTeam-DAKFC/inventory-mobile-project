import 'dart:async';

import '../core/storage/notification_registration_storage.dart';
import '../domain/models/notification_token.dart';
import '../domain/repositories/notification_token_repository.dart';
import 'firebase_messaging_gateway.dart';

typedef CurrentNotificationUserId = String? Function();

final class PushNotificationService {
  PushNotificationService(this._messaging, this._repository, this._storage);

  final FirebaseMessagingGateway _messaging;
  final NotificationTokenRepository _repository;
  final NotificationRegistrationStorage _storage;

  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> requestPermission() async {
    try {
      await _messaging.requestPermission();
    } catch (_) {
      // Notification registration must never block the app.
    }
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> registerForUser(String? userId) async {
    if (!_hasValue(userId)) return;

    final token = await getToken();
    if (!_hasValue(token)) return;

    await _registerToken(token: token!, userId: userId!);
  }

  Future<void> unregisterCurrentRegistration() async {
    try {
      final registration = await _storage.read();
      if (registration != null) {
        await _repository.deleteNotificationToken(
          registration.notificationTokenId,
        );
      }
    } catch (_) {
      // Token deletion is best-effort and must never block logout.
    } finally {
      try {
        await _storage.clear();
      } catch (_) {
        // Storage cleanup failures must never block logout.
      }
    }
  }

  void startTokenRefreshListener(CurrentNotificationUserId currentUserId) {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (token) async {
        final String? userId;
        try {
          userId = currentUserId();
        } catch (_) {
          return;
        }
        if (!_hasValue(userId) || !_hasValue(token)) return;

        await _registerToken(token: token, userId: userId!);
      },
      onError: (_) {
        // Token refresh failures are retried by Firebase Messaging.
      },
    );
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<void> _registerToken({
    required String token,
    required String userId,
  }) async {
    try {
      final result = await _repository.createNotificationToken(
        token: token,
        platform: PlatformType.android,
      );
      final registeredToken = result.dataOrNull;
      if (registeredToken == null) return;

      await _storage.save(
        StoredNotificationRegistration(
          notificationTokenId: registeredToken.id,
          userId: userId,
        ),
      );
    } catch (_) {
      // Registration is best-effort and must not escape to session or UI flows.
    }
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
