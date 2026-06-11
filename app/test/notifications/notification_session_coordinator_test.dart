import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/core/storage/notification_registration_storage.dart';
import 'package:inventory_mobile/domain/models/notification_token.dart';
import 'package:inventory_mobile/domain/repositories/notification_token_repository.dart';
import 'package:inventory_mobile/notifications/firebase_messaging_gateway.dart';
import 'package:inventory_mobile/notifications/notification_session_coordinator.dart';
import 'package:inventory_mobile/notifications/push_notification_service.dart';

void main() {
  test('authenticated user requests permission and registers token', () async {
    final messaging = _FakeMessagingGateway();
    final repository = _FakeRepository();
    final service = PushNotificationService(
      messaging,
      repository,
      _FakeStorage(),
    );
    final sut = DefaultNotificationSessionCoordinator(() => service);
    addTearDown(service.dispose);

    await sut.onAuthenticated('user-id');

    expect(messaging.permissionRequests, 1);
    expect(repository.createdTokens, ['fcm-token']);
  });

  test('beforeLogout unregisters the stored notification token', () async {
    final repository = _FakeRepository();
    final storage = _FakeStorage()
      ..registration = const StoredNotificationRegistration(
        notificationTokenId: 'backend-id',
        userId: 'user-id',
      );
    final service = PushNotificationService(
      _FakeMessagingGateway(),
      repository,
      storage,
    );
    final sut = DefaultNotificationSessionCoordinator(() => service);
    addTearDown(service.dispose);

    await sut.beforeLogout();

    expect(repository.deletedTokenIds, ['backend-id']);
    expect(storage.clearCalls, 1);
  });
}

final class _FakeMessagingGateway implements FirebaseMessagingGateway {
  int permissionRequests = 0;

  @override
  Future<String?> getToken() async => 'fcm-token';

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<void> requestPermission() async {
    permissionRequests += 1;
  }
}

final class _FakeRepository implements NotificationTokenRepository {
  final List<String> createdTokens = [];
  final List<String> deletedTokenIds = [];

  @override
  Future<AppResult<NotificationToken>> createNotificationToken({
    required String token,
    required PlatformType platform,
  }) async {
    createdTokens.add(token);
    return AppSuccess(
      NotificationToken(
        id: 'backend-id',
        token: token,
        platform: platform,
        createdAt: DateTime.utc(2026, 6, 10),
      ),
    );
  }

  @override
  Future<AppResult<void>> deleteNotificationToken(String tokenId) async {
    deletedTokenIds.add(tokenId);
    return const AppSuccess(null);
  }
}

final class _FakeStorage implements NotificationRegistrationStorage {
  StoredNotificationRegistration? registration;
  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls += 1;
    registration = null;
  }

  @override
  Future<StoredNotificationRegistration?> read() async => registration;

  @override
  Future<void> save(StoredNotificationRegistration registration) async {
    this.registration = registration;
  }
}
