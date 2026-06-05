import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/storage/auth_token_storage.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage secureStorage;
  late SecureAuthTokenStorage sut;

  const accessKey = 'auth.access_token';
  const expiresKey = 'auth.expires_at';

  setUp(() {
    secureStorage = _MockSecureStorage();
    sut = SecureAuthTokenStorage(secureStorage: secureStorage);
  });

  setUpAll(() {
    registerFallbackValue('');
  });

  group('SecureAuthTokenStorage.saveToken', () {
    test('writes accessToken and expiresAt as ISO-8601 UTC', () async {
      when(() => secureStorage.write(
              key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final expiresAt = DateTime.utc(2026, 6, 2, 20, 0, 0);
      await sut.saveToken(
        StoredAuthToken(accessToken: 'tok-123', expiresAt: expiresAt),
      );

      verify(() => secureStorage.write(key: accessKey, value: 'tok-123'))
          .called(1);
      verify(() => secureStorage.write(
            key: expiresKey,
            value: '2026-06-02T20:00:00.000Z',
          )).called(1);
    });
  });

  group('SecureAuthTokenStorage.readToken', () {
    test('returns null when no token is stored', () async {
      when(() => secureStorage.read(key: accessKey))
          .thenAnswer((_) async => null);
      when(() => secureStorage.read(key: expiresKey))
          .thenAnswer((_) async => null);

      expect(await sut.readToken(), isNull);
    });

    test('returns null when accessToken is missing', () async {
      when(() => secureStorage.read(key: accessKey))
          .thenAnswer((_) async => null);
      when(() => secureStorage.read(key: expiresKey))
          .thenAnswer((_) async => '2026-06-02T20:00:00.000Z');

      expect(await sut.readToken(), isNull);
    });

    test('returns the stored token when both fields are present', () async {
      when(() => secureStorage.read(key: accessKey))
          .thenAnswer((_) async => 'tok-123');
      when(() => secureStorage.read(key: expiresKey))
          .thenAnswer((_) async => '2026-06-02T20:00:00.000Z');

      final token = await sut.readToken();

      expect(token, isNotNull);
      expect(token!.accessToken, 'tok-123');
      expect(token.expiresAt, DateTime.utc(2026, 6, 2, 20, 0, 0));
    });

    test('clears and returns null when expiresAt is corrupted', () async {
      when(() => secureStorage.read(key: accessKey))
          .thenAnswer((_) async => 'tok-123');
      when(() => secureStorage.read(key: expiresKey))
          .thenAnswer((_) async => 'not-a-date');
      when(() => secureStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      expect(await sut.readToken(), isNull);
      verify(() => secureStorage.delete(key: accessKey)).called(1);
      verify(() => secureStorage.delete(key: expiresKey)).called(1);
    });
  });

  group('SecureAuthTokenStorage.clear', () {
    test('deletes both keys from the underlying storage', () async {
      when(() => secureStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await sut.clear();

      verify(() => secureStorage.delete(key: accessKey)).called(1);
      verify(() => secureStorage.delete(key: expiresKey)).called(1);
    });
  });
}
