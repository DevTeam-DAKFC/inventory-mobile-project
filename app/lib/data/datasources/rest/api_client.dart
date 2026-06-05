import 'package:dio/dio.dart';

import '../../../core/constants/api_config.dart';

final class ApiClient {
  ApiClient(this.config) : dio = _buildDio(config);

  final ApiConfig config;
  final Dio dio;

  static const Duration defaultConnectTimeout = Duration(seconds: 10);
  static const Duration defaultReceiveTimeout = Duration(seconds: 15);

  static Dio _buildDio(ApiConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: defaultConnectTimeout,
        receiveTimeout: defaultReceiveTimeout,
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );
  }
}
