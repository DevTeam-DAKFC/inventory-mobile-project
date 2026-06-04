import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
