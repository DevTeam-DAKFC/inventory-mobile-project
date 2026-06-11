import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/core/storage/notification_registration_storage.dart';
import 'package:inventory_mobile/domain/models/notification_token.dart';
import 'package:inventory_mobile/domain/repositories/notification_token_repository.dart';
import 'package:inventory_mobile/notifications/firebase_messaging_gateway.dart';
import 'package:inventory_mobile/notifications/push_notification_service.dart';

void main() {
  late _FakeFirebaseMessagingGateway messaging;
  late _FakeNotificationTokenRepository repository;
  late _FakeNotificationRegistrationStorage storage;
  late PushNotificationService sut;

  setUp(() {
    messaging = _FakeFirebaseMessagingGateway();
    repository = _FakeNotificationTokenRepository();
    storage = _FakeNotificationRegistrationStorage();
    sut = PushNotificationService(messaging, repository, storage);
  });

  tearDown(() async {
    sut.dispose();
    await messaging.dispose();
  });

  test('requestPermission completes safely when Firebase fails', () async {
    messaging.permissionError = StateError('permission failure');

    await expectLater(sut.requestPermission(), completes);

    expect(messaging.permissionRequests, 1);
  });

  test('does not register when FCM token is null', () async {
    messaging.token = null;

    await sut.registerForUser('user-id');

    expect(repository.createCalls, isEmpty);
    expect(storage.saved, isEmpty);
  });

  test('does not register when user is absent', () async {
    messaging.token = 'fcm-token';

    await sut.registerForUser(null);

    expect(messaging.getTokenCalls, 0);
    expect(repository.createCalls, isEmpty);
  });

  test('registers token and stores registration id after success', () async {
    messaging.token = 'fcm-token';
    repository.createResult = AppSuccess(_notificationToken('backend-id'));

    await sut.registerForUser('user-id');

    expect(repository.createCalls, [
      const _CreateCall(token: 'fcm-token', platform: PlatformType.android),
    ]);
    expect(storage.saved.single.notificationTokenId, 'backend-id');
    expect(storage.saved.single.userId, 'user-id');
  });

  test('does not throw or save when repository returns failure', () async {
    messaging.token = 'fcm-token';
    repository.createResult = const AppFailure(
      AppException(
        code: AppErrorCode.networkError,
        message: 'Backend unavailable.',
      ),
    );

    await expectLater(sut.registerForUser('user-id'), completes);

    expect(repository.createCalls, hasLength(1));
    expect(storage.saved, isEmpty);
  });

  test('onTokenRefresh registers new token when user exists', () async {
    repository.createResult = AppSuccess(_notificationToken('refreshed-id'));
    sut.startTokenRefreshListener(() => 'user-id');

    messaging.refreshController.add('refreshed-fcm-token');
    await _flushEvents();

    expect(repository.createCalls.single.token, 'refreshed-fcm-token');
    expect(storage.saved.single.notificationTokenId, 'refreshed-id');
    expect(storage.saved.single.userId, 'user-id');
  });

  test('onTokenRefresh does not call backend without user', () async {
    sut.startTokenRefreshListener(() => null);

    messaging.refreshController.add('refreshed-fcm-token');
    await _flushEvents();

    expect(repository.createCalls, isEmpty);
    expect(storage.saved, isEmpty);
  });

  test('unregister deletes stored token id and clears storage', () async {
    storage.registration = const StoredNotificationRegistration(
      notificationTokenId: 'backend-id',
      userId: 'user-id',
    );

    await sut.unregisterCurrentRegistration();

    expect(repository.deleteCalls, ['backend-id']);
    expect(storage.clearCalls, 1);
  });

  test('unregister clears storage when backend deletion fails', () async {
    storage.registration = const StoredNotificationRegistration(
      notificationTokenId: 'backend-id',
      userId: 'user-id',
    );
    repository.deleteError = StateError('delete failed');

    await expectLater(sut.unregisterCurrentRegistration(), completes);

    expect(repository.deleteCalls, ['backend-id']);
    expect(storage.clearCalls, 1);
  });
}

Future<void> _flushEvents() => Future<void>.delayed(Duration.zero);

NotificationToken _notificationToken(String id) {
  return NotificationToken(
    id: id,
    token: 'server-token-value',
    platform: PlatformType.android,
    createdAt: DateTime.utc(2026, 6, 10),
  );
}

final class _FakeFirebaseMessagingGateway implements FirebaseMessagingGateway {
  final refreshController = StreamController<String>.broadcast();

  String? token;
  Object? permissionError;
  int permissionRequests = 0;
  int getTokenCalls = 0;

  @override
  Future<String?> getToken() async {
    getTokenCalls += 1;
    return token;
  }

  @override
  Stream<String> get onTokenRefresh => refreshController.stream;

  @override
  Future<void> requestPermission() async {
    permissionRequests += 1;
    if (permissionError case final error?) throw error;
  }

  Future<void> dispose() => refreshController.close();
}

final class _FakeNotificationTokenRepository
    implements NotificationTokenRepository {
  AppResult<NotificationToken> createResult = AppSuccess(
    _notificationToken('default-id'),
  );
  final List<_CreateCall> createCalls = [];
  final List<String> deleteCalls = [];
  Object? deleteError;

  @override
  Future<AppResult<NotificationToken>> createNotificationToken({
    required String token,
    required PlatformType platform,
  }) async {
    createCalls.add(_CreateCall(token: token, platform: platform));
    return createResult;
  }

  @override
  Future<AppResult<void>> deleteNotificationToken(String tokenId) async {
    deleteCalls.add(tokenId);
    if (deleteError case final error?) throw error;
    return const AppSuccess(null);
  }
}

final class _FakeNotificationRegistrationStorage
    implements NotificationRegistrationStorage {
  final List<StoredNotificationRegistration> saved = [];
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
    saved.add(registration);
  }
}

final class _CreateCall {
  const _CreateCall({required this.token, required this.platform});

  final String token;
  final PlatformType platform;

  @override
  bool operator ==(Object other) {
    return other is _CreateCall &&
        other.token == token &&
        other.platform == platform;
  }

  @override
  int get hashCode => Object.hash(token, platform);
}
