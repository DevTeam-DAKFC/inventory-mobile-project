import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class StoredAuthToken {
  const StoredAuthToken({required this.accessToken, required this.expiresAt});

  final String accessToken;
  final DateTime expiresAt;
}

abstract class AuthTokenStorage {
  Future<void> saveToken(StoredAuthToken token);

  Future<StoredAuthToken?> readToken();

  Future<void> clear();
}

final class SecureAuthTokenStorage implements AuthTokenStorage {
  SecureAuthTokenStorage({FlutterSecureStorage? secureStorage})
    : _storage =
          secureStorage ??
          const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'auth.access_token';
  static const String _expiresAtKey = 'auth.expires_at';

  @override
  Future<void> saveToken(StoredAuthToken token) async {
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _expiresAtKey, value: token.expiresAt.toUtc().toIso8601String());
  }

  @override
  Future<StoredAuthToken?> readToken() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final expiresAtRaw = await _storage.read(key: _expiresAtKey);
    if (accessToken == null || expiresAtRaw == null) {
      return null;
    }
    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) {
      await clear();
      return null;
    }
    return StoredAuthToken(accessToken: accessToken, expiresAt: expiresAt);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _expiresAtKey);
  }
}
