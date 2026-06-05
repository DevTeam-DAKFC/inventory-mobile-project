import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/constants/api_config.dart';

void main() {
  group('ApiConfig', () {
    group('defaultBaseUrlFor', () {
      test('returns 10.0.2.2 URL on Android', () {
        expect(
          ApiConfig.defaultBaseUrlFor(TargetPlatform.android),
          'http://10.0.2.2:5225',
        );
      });

      test('returns localhost URL on iOS', () {
        expect(
          ApiConfig.defaultBaseUrlFor(TargetPlatform.iOS),
          'http://localhost:5225',
        );
      });

      test('returns localhost URL on macOS', () {
        expect(
          ApiConfig.defaultBaseUrlFor(TargetPlatform.macOS),
          'http://localhost:5225',
        );
      });

      test('returns localhost URL on Linux', () {
        expect(
          ApiConfig.defaultBaseUrlFor(TargetPlatform.linux),
          'http://localhost:5225',
        );
      });

      test('returns localhost URL on Windows', () {
        expect(
          ApiConfig.defaultBaseUrlFor(TargetPlatform.windows),
          'http://localhost:5225',
        );
      });
    });

    group('resolve', () {
      test('uses the provided custom base URL', () {
        final config = ApiConfig.resolve(
          providedBaseUrl: 'http://api.example.com:8080',
          platform: TargetPlatform.linux,
        );

        expect(config.baseUrl, 'http://api.example.com:8080');
      });

      test('strips a trailing slash from the provided URL', () {
        final config = ApiConfig.resolve(
          providedBaseUrl: 'http://api.example.com:8080/',
          platform: TargetPlatform.linux,
        );

        expect(config.baseUrl, 'http://api.example.com:8080');
      });

      test('falls back to the Android default when provided URL is empty', () {
        final config = ApiConfig.resolve(
          providedBaseUrl: '',
          platform: TargetPlatform.android,
        );

        expect(config.baseUrl, 'http://10.0.2.2:5225');
      });

      test('falls back to the non-Android default when provided URL is empty',
          () {
        final config = ApiConfig.resolve(
          providedBaseUrl: '',
          platform: TargetPlatform.iOS,
        );

        expect(config.baseUrl, 'http://localhost:5225');
      });
    });
  });
}
