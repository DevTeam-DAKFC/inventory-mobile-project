import 'push_notification_service.dart';

abstract class NotificationSessionCoordinator {
  Future<void> onAuthenticated(String userId);

  Future<void> beforeLogout();
}

final class DefaultNotificationSessionCoordinator
    implements NotificationSessionCoordinator {
  DefaultNotificationSessionCoordinator(this._pushNotificationService);

  final PushNotificationService Function() _pushNotificationService;

  String? _currentUserId;

  @override
  Future<void> onAuthenticated(String userId) async {
    _currentUserId = userId;
    try {
      final service = _pushNotificationService();
      service.startTokenRefreshListener(() => _currentUserId);
      await service.requestPermission();
      await service.registerForUser(userId);
    } catch (_) {}
  }

  @override
  Future<void> beforeLogout() async {
    _currentUserId = null;
    try {
      await _pushNotificationService().unregisterCurrentRegistration();
    } catch (_) {}
  }
}
