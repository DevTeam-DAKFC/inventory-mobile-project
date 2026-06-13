import 'package:dio/dio.dart';

import '../../../core/auth/access_token_provider.dart';
import '../../../core/constants/api_config.dart';

final class ApiClient {
  ApiClient(this.config, {AccessTokenProvider? accessTokenProvider})
    : dio = _buildDio(config, accessTokenProvider);

  final ApiConfig config;
  final Dio dio;

  static const Duration defaultConnectTimeout = Duration(seconds: 10);
  static const Duration defaultReceiveTimeout = Duration(seconds: 15);

  static Dio _buildDio(
    ApiConfig config,
    AccessTokenProvider? accessTokenProvider,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: defaultConnectTimeout,
        receiveTimeout: defaultReceiveTimeout,
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );

    if (accessTokenProvider != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await accessTokenProvider.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );
    }

    return dio;
  }
}
