import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/auth/access_token_provider.dart';
import 'package:inventory_mobile/core/constants/api_config.dart';
import 'package:inventory_mobile/data/datasources/rest/api_client.dart';

void main() {
  group('ApiClient', () {
    test('builds Dio with the ApiConfig base URL', () {
      const config = ApiConfig(baseUrl: 'http://localhost:5225');
      final client = ApiClient(config);

      expect(client.dio.options.baseUrl, 'http://localhost:5225');
    });

    test('uses the configured default timeouts', () {
      const config = ApiConfig(baseUrl: 'http://localhost:5225');
      final client = ApiClient(config);

      expect(
        client.dio.options.connectTimeout,
        ApiClient.defaultConnectTimeout,
      );
      expect(
        client.dio.options.receiveTimeout,
        ApiClient.defaultReceiveTimeout,
      );
    });

    test('declares JSON Accept header and response type', () {
      const config = ApiConfig(baseUrl: 'http://localhost:5225');
      final client = ApiClient(config);

      expect(client.dio.options.responseType, ResponseType.json);
      expect(client.dio.options.headers['Accept'], 'application/json');
    });

    test('adds Authorization header when an access token is available', () async {
      const config = ApiConfig(baseUrl: 'http://localhost:5225');
      final adapter = _HeaderCapturingAdapter();
      final client = ApiClient(
        config,
        accessTokenProvider: const DevAccessTokenProvider(token: 'abc123'),
      )..dio.httpClientAdapter = adapter;

      await client.dio.get<dynamic>('/inventory-movements');

      expect(adapter.lastHeaders['Authorization'], 'Bearer abc123');
    });

    test('does not add Authorization header when no token is available', () async {
      const config = ApiConfig(baseUrl: 'http://localhost:5225');
      final adapter = _HeaderCapturingAdapter();
      final client = ApiClient(
        config,
        accessTokenProvider: const DevAccessTokenProvider(token: ''),
      )..dio.httpClientAdapter = adapter;

      await client.dio.get<dynamic>('/health');

      expect(adapter.lastHeaders.containsKey('Authorization'), isFalse);
    });
  });
}

final class _HeaderCapturingAdapter implements HttpClientAdapter {
  Map<String, dynamic> lastHeaders = const {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastHeaders = Map<String, dynamic>.from(options.headers);
    return ResponseBody.fromString(
      jsonEncode({'status': 'ok'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
