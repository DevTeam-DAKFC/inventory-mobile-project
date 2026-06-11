import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef LocalNotificationTapHandler = void Function();

abstract class LocalNotificationService {
  Future<void> initialize(LocalNotificationTapHandler onTap);

  Future<void> show({required String title, required String body});
}

final class DefaultLocalNotificationService
    implements LocalNotificationService {
  DefaultLocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const channelId = 'inventory_alerts';
  static const channelName = 'Alertas de inventario';
  static const channelDescription =
      'Alertas de bajo stock y productos agotados';

  final FlutterLocalNotificationsPlugin _plugin;
  int _nextNotificationId = 0;

  @override
  Future<void> initialize(LocalNotificationTapHandler onTap) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (_) => onTap(),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
          ),
        );
  }

  @override
  Future<void> show({required String title, required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      id: _nextNotificationId++,
      title: title,
      body: body,
      notificationDetails: details,
      payload: channelId,
    );
  }
}
