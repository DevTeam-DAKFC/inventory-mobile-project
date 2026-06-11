import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FirebaseMessagingGateway {
  Future<void> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;
}

final class DefaultFirebaseMessagingGateway
    implements FirebaseMessagingGateway {
  DefaultFirebaseMessagingGateway({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
