import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/backend_health.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/rest/rest_api_health_data_source.dart';
import '../mappers/backend_health_mapper.dart';

/// Default [HealthRepository] backed by [RestApiHealthDataSource].
///
/// Converts data-source outcomes into the shared [AppResult] surface so
/// callers never observe raw [Exception]s and never have to handle anything
/// outside the [AppErrorCode] taxonomy.
final class HealthRepositoryImpl implements HealthRepository {
  const HealthRepositoryImpl(this._dataSource);

  final RestApiHealthDataSource _dataSource;

  @override
  Future<AppResult<BackendHealth>> checkBackendHealth() async {
    try {
      final dto = await _dataSource.checkBackendHealth();
      return AppSuccess(BackendHealthMapper.toDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error checking backend health.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
