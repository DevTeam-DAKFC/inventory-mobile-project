import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class StoredNotificationRegistration {
  const StoredNotificationRegistration({
    required this.notificationTokenId,
    required this.userId,
  });

  final String notificationTokenId;
  final String userId;
}

abstract class NotificationRegistrationStorage {
  Future<void> save(StoredNotificationRegistration registration);

  Future<StoredNotificationRegistration?> read();

  Future<void> clear();
}

final class SecureNotificationRegistrationStorage
    implements NotificationRegistrationStorage {
  SecureNotificationRegistrationStorage({FlutterSecureStorage? secureStorage})
    : _storage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  static const String _notificationTokenIdKey =
      'notifications.registration_token_id';
  static const String _userIdKey = 'notifications.registration_user_id';

  @override
  Future<void> save(StoredNotificationRegistration registration) async {
    await _storage.write(
      key: _notificationTokenIdKey,
      value: registration.notificationTokenId,
    );
    await _storage.write(key: _userIdKey, value: registration.userId);
  }

  @override
  Future<StoredNotificationRegistration?> read() async {
    final notificationTokenId = await _storage.read(
      key: _notificationTokenIdKey,
    );
    final userId = await _storage.read(key: _userIdKey);
    if (notificationTokenId == null || userId == null) return null;

    return StoredNotificationRegistration(
      notificationTokenId: notificationTokenId,
      userId: userId,
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _notificationTokenIdKey);
    await _storage.delete(key: _userIdKey);
  }
}
