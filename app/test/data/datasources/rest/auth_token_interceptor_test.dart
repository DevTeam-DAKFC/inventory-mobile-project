import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/storage/auth_token_storage.dart';
import 'package:inventory_mobile/data/datasources/rest/auth_token_interceptor.dart';

class _FakeStorage implements AuthTokenStorage {
  StoredAuthToken? token;
  int reads = 0;

  @override
  Future<void> saveToken(StoredAuthToken token) async {
    this.token = token;
  }

  @override
  Future<StoredAuthToken?> readToken() async {
    reads++;
    return token;
  }

  @override
  Future<void> clear() async {
    token = null;
  }
}

class _CapturingHandler extends RequestInterceptorHandler {
  RequestOptions? capturedOptions;

  @override
  void next(RequestOptions requestOptions) {
    capturedOptions = requestOptions;
  }
}

void main() {
  late _FakeStorage storage;
  late AuthTokenInterceptor sut;

  setUp(() {
    storage = _FakeStorage();
    sut = AuthTokenInterceptor(storage);
  });

  test('does not attach a header when no token is stored', () async {
    final handler = _CapturingHandler();
    final options = RequestOptions(path: '/auth/me');

    await sut.onRequest(options, handler);

    expect(handler.capturedOptions?.headers['Authorization'], isNull);
    expect(storage.reads, 1);
  });

  test('attaches Bearer header when a token is stored', () async {
    storage.token = StoredAuthToken(
      accessToken: 'tok-xyz',
      expiresAt: DateTime.utc(2099),
    );
    final handler = _CapturingHandler();
    final options = RequestOptions(path: '/auth/me');

    await sut.onRequest(options, handler);

    expect(
      handler.capturedOptions?.headers['Authorization'],
      'Bearer tok-xyz',
    );
  });

  test('does not override an existing Authorization header', () async {
    storage.token = StoredAuthToken(
      accessToken: 'tok-xyz',
      expiresAt: DateTime.utc(2099),
    );
    final handler = _CapturingHandler();
    final options = RequestOptions(
      path: '/auth/login',
      headers: <String, dynamic>{'Authorization': 'Bearer overridden'},
    );

    await sut.onRequest(options, handler);

    expect(
      handler.capturedOptions?.headers['Authorization'],
      'Bearer overridden',
    );
    expect(storage.reads, 0);
  });
}
