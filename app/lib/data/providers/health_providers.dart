import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_config.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/backend_health.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/rest/api_client.dart';
import '../datasources/rest/rest_api_health_data_source.dart';
import '../repositories/health_repository_impl.dart';

final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.defaultForApp(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(apiConfigProvider)),
);

final healthDataSourceProvider = Provider<RestApiHealthDataSource>(
  (ref) => RestApiHealthDataSource(ref.watch(apiClientProvider).dio),
);

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) => HealthRepositoryImpl(ref.watch(healthDataSourceProvider)),
);

final backendHealthProvider = FutureProvider<AppResult<BackendHealth>>(
  (ref) => ref.watch(healthRepositoryProvider).checkBackendHealth(),
);
