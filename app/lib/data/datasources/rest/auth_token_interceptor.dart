import 'package:dio/dio.dart';

import '../../../core/storage/auth_token_storage.dart';

/// Dio interceptor that attaches `Authorization: Bearer <accessToken>`
/// to outbound requests when an access token is currently saved.
///
/// Does **not** redirect or log out on 401 — those concerns belong to a
/// later block once the session restore flow is in place.
class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor(this._tokenStorage);

  final AuthTokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }
    final token = await _tokenStorage.readToken();
    if (token != null && token.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    handler.next(options);
  }
}
