import 'package:firebase_messaging/firebase_messaging.dart';

final class PushMessage {
  const PushMessage({this.title, this.body, this.data = const {}});

  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  bool get isInventoryAlert {
    return data['type'] == 'low_stock' || data['type'] == 'out_of_stock';
  }
}

abstract class FirebaseMessagingGateway {
  Future<void> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Stream<PushMessage> get onMessage;

  Stream<PushMessage> get onMessageOpenedApp;

  Future<PushMessage?> getInitialMessage();
}

final class DefaultFirebaseMessagingGateway
    implements FirebaseMessagingGateway {
  DefaultFirebaseMessagingGateway([this._messaging]);

  final FirebaseMessaging? _messaging;

  FirebaseMessaging get _instance => _messaging ?? FirebaseMessaging.instance;

  @override
  Future<void> requestPermission() async {
    await _instance.requestPermission();
  }

  @override
  Future<String?> getToken() => _instance.getToken();

  @override
  Stream<String> get onTokenRefresh => _instance.onTokenRefresh;

  @override
  Stream<PushMessage> get onMessage => FirebaseMessaging.onMessage.map(_map);

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_map);

  @override
  Future<PushMessage?> getInitialMessage() async {
    final message = await _instance.getInitialMessage();
    return message == null ? null : _map(message);
  }

  PushMessage _map(RemoteMessage message) {
    return PushMessage(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}
