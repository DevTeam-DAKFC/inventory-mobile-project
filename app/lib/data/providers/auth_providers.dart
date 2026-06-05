import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/auth_token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/rest/auth_token_interceptor.dart';
import '../datasources/rest/rest_api_auth_data_source.dart';
import '../repositories/auth_repository_impl.dart';
import 'health_providers.dart';

/// Secure on-device storage for the access token.
final tokenStorageProvider = Provider<AuthTokenStorage>(
  (ref) => SecureAuthTokenStorage(),
);

final authTokenInterceptorProvider = Provider<AuthTokenInterceptor>(
  (ref) => AuthTokenInterceptor(ref.watch(tokenStorageProvider)),
);

/// Returns the shared [Dio] instance from [apiClientProvider] after
/// ensuring the [AuthTokenInterceptor] is registered on it.
///
/// Wiring lives in a provider (instead of inside `ApiClient`) so this
/// block does not touch `ApiClient` itself.
final authenticatedDioProvider = Provider<Dio>((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  final interceptor = ref.watch(authTokenInterceptorProvider);
  if (!dio.interceptors.contains(interceptor)) {
    dio.interceptors.add(interceptor);
  }
  return dio;
});

final authDataSourceProvider = Provider<RestApiAuthDataSource>(
  (ref) => RestApiAuthDataSource(ref.watch(authenticatedDioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    dataSource: ref.watch(authDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);
