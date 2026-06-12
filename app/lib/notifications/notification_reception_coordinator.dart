import 'dart:async';

import 'firebase_messaging_gateway.dart';
import 'local_notification_service.dart';

typedef AlertsNavigationRequest = void Function();

final class NotificationReceptionCoordinator {
  NotificationReceptionCoordinator(
    this._messaging,
    this._localNotifications,
    this._openAlerts,
  );

  static const fallbackTitle = 'Alerta de inventario';
  static const fallbackBody = 'Hay una actualizacion en tu inventario.';

  final FirebaseMessagingGateway _messaging;
  final LocalNotificationService _localNotifications;
  final AlertsNavigationRequest _openAlerts;

  StreamSubscription<PushMessage>? _foregroundSubscription;
  StreamSubscription<PushMessage>? _openedSubscription;

  Future<void> initialize() async {
    try {
      await _localNotifications.initialize(_requestAlertsNavigation);
      _foregroundSubscription = _messaging.onMessage.listen(
        _showForegroundMessage,
      );
      _openedSubscription = _messaging.onMessageOpenedApp.listen(
        (_) => _requestAlertsNavigation(),
      );
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) _requestAlertsNavigation();
    } catch (_) {
      // Notification reception must never block app startup.
    }
  }

  void dispose() {
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();
  }

  Future<void> _showForegroundMessage(PushMessage message) async {
    try {
      await _localNotifications.show(
        title: _safeText(message.title, fallbackTitle),
        body: _safeText(message.body, fallbackBody),
      );
    } catch (_) {
      // Foreground notification failures must not affect the app.
    }
  }

  void _requestAlertsNavigation() {
    try {
      _openAlerts();
    } catch (_) {
      // Navigation may be unavailable while the router is starting.
    }
  }

  String _safeText(String? value, String fallback) {
    return value == null || value.trim().isEmpty ? fallback : value.trim();
  }
}
