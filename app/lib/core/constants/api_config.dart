import 'package:flutter/foundation.dart';

/// when no override is provided. Network details such as the Dio client live
/// in `data/datasources/rest/` and depend on this config.
final class ApiConfig {
  const ApiConfig({required this.baseUrl});

  final String baseUrl;

  static const int defaultBackendPort = 5225;

  /// Build-time override read from `--dart-define=BACKEND_BASE_URL=...`.
  static const String _envBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');

  /// override when present; otherwise derives the URL from the current
  /// [defaultTargetPlatform].
  factory ApiConfig.defaultForApp() =>
      ApiConfig.resolve(providedBaseUrl: _envBaseUrl, platform: defaultTargetPlatform);

  factory ApiConfig.resolve({required String providedBaseUrl, required TargetPlatform platform}) {
    final raw = providedBaseUrl.isEmpty ? defaultBaseUrlFor(platform) : providedBaseUrl;
    return ApiConfig(baseUrl: _stripTrailingSlash(raw));
  }

  static String defaultBaseUrlFor(TargetPlatform platform) {
    if (platform == TargetPlatform.android) {
      return 'http://10.0.2.2:$defaultBackendPort';
    }
    return 'http://localhost:$defaultBackendPort';
  }

  static String _stripTrailingSlash(String url) {
    if (url.length > 1 && url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }
}
