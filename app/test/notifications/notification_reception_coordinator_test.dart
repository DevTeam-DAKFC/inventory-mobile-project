import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/notifications/firebase_messaging_gateway.dart';
import 'package:inventory_mobile/notifications/local_notification_service.dart';
import 'package:inventory_mobile/notifications/notification_reception_coordinator.dart';

void main() {
  late _FakeMessagingGateway messaging;
  late _FakeLocalNotificationService localNotifications;
  late int navigationRequests;
  late NotificationReceptionCoordinator sut;

  setUp(() {
    messaging = _FakeMessagingGateway();
    localNotifications = _FakeLocalNotificationService();
    navigationRequests = 0;
    sut = NotificationReceptionCoordinator(
      messaging,
      localNotifications,
      () => navigationRequests += 1,
    );
  });

  tearDown(() async {
    sut.dispose();
    await messaging.dispose();
  });

  test('onMessage shows local notification with title and body', () async {
    await sut.initialize();

    messaging.messages.add(
      const PushMessage(title: 'Stock bajo', body: 'Arroz tiene poco stock'),
    );
    await _flushEvents();

    expect(localNotifications.shown.single.title, 'Stock bajo');
    expect(localNotifications.shown.single.body, 'Arroz tiene poco stock');
  });

  test('missing title and body use safe fallbacks', () async {
    await sut.initialize();

    messaging.messages.add(const PushMessage(title: ' ', body: null));
    await _flushEvents();

    expect(
      localNotifications.shown.single.title,
      NotificationReceptionCoordinator.fallbackTitle,
    );
    expect(
      localNotifications.shown.single.body,
      NotificationReceptionCoordinator.fallbackBody,
    );
  });

  test('remote notification tap requests alerts navigation', () async {
    await sut.initialize();

    messaging.openedMessages.add(const PushMessage(data: {'type': 'unknown'}));
    await _flushEvents();

    expect(navigationRequests, 1);
  });

  test('local notification tap requests alerts navigation', () async {
    await sut.initialize();

    localNotifications.tap();

    expect(navigationRequests, 1);
  });

  test('initial message requests alerts navigation', () async {
    messaging.initialMessage = const PushMessage(
      data: {'type': 'out_of_stock'},
    );

    await sut.initialize();

    expect(navigationRequests, 1);
  });

  test('recognizes inventory payload types and tolerates unknown type', () {
    expect(
      const PushMessage(data: {'type': 'low_stock'}).isInventoryAlert,
      isTrue,
    );
    expect(
      const PushMessage(data: {'type': 'out_of_stock'}).isInventoryAlert,
      isTrue,
    );
    expect(
      const PushMessage(data: {'type': 'something_else'}).isInventoryAlert,
      isFalse,
    );
  });
}

Future<void> _flushEvents() => Future<void>.delayed(Duration.zero);

final class _FakeMessagingGateway implements FirebaseMessagingGateway {
  final messages = StreamController<PushMessage>.broadcast();
  final openedMessages = StreamController<PushMessage>.broadcast();
  PushMessage? initialMessage;

  @override
  Future<PushMessage?> getInitialMessage() async => initialMessage;

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<PushMessage> get onMessage => messages.stream;

  @override
  Stream<PushMessage> get onMessageOpenedApp => openedMessages.stream;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<void> requestPermission() async {}

  Future<void> dispose() async {
    await messages.close();
    await openedMessages.close();
  }
}

final class _FakeLocalNotificationService implements LocalNotificationService {
  final List<_ShownNotification> shown = [];
  LocalNotificationTapHandler? onTap;

  @override
  Future<void> initialize(LocalNotificationTapHandler onTap) async {
    this.onTap = onTap;
  }

  @override
  Future<void> show({required String title, required String body}) async {
    shown.add(_ShownNotification(title, body));
  }

  void tap() => onTap?.call();
}

final class _ShownNotification {
  const _ShownNotification(this.title, this.body);

  final String title;
  final String body;
}
