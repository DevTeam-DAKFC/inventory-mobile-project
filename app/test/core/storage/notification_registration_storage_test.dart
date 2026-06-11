import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/storage/notification_registration_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage secureStorage;
  late SecureNotificationRegistrationStorage sut;

  const tokenIdKey = 'notifications.registration_token_id';
  const userIdKey = 'notifications.registration_user_id';

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    secureStorage = _MockSecureStorage();
    sut = SecureNotificationRegistrationStorage(secureStorage: secureStorage);
  });

  test('saves notificationTokenId and userId', () async {
    when(
      () => secureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});

    await sut.save(
      const StoredNotificationRegistration(
        notificationTokenId: 'notification-token-id',
        userId: 'user-id',
      ),
    );

    verify(
      () =>
          secureStorage.write(key: tokenIdKey, value: 'notification-token-id'),
    ).called(1);
    verify(
      () => secureStorage.write(key: userIdKey, value: 'user-id'),
    ).called(1);
  });

  test('reads a complete registration', () async {
    when(
      () => secureStorage.read(key: tokenIdKey),
    ).thenAnswer((_) async => 'notification-token-id');
    when(
      () => secureStorage.read(key: userIdKey),
    ).thenAnswer((_) async => 'user-id');

    final registration = await sut.read();

    expect(registration?.notificationTokenId, 'notification-token-id');
    expect(registration?.userId, 'user-id');
  });

  test('returns null when registration is incomplete', () async {
    when(
      () => secureStorage.read(key: tokenIdKey),
    ).thenAnswer((_) async => 'notification-token-id');
    when(
      () => secureStorage.read(key: userIdKey),
    ).thenAnswer((_) async => null);

    expect(await sut.read(), isNull);
  });

  test('clears notificationTokenId and userId', () async {
    when(
      () => secureStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});

    await sut.clear();

    verify(() => secureStorage.delete(key: tokenIdKey)).called(1);
    verify(() => secureStorage.delete(key: userIdKey)).called(1);
  });
}
