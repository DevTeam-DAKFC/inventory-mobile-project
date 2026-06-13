import '../../core/result/app_result.dart';
import '../models/backend_health.dart';

/// Contract for checking the inventory backend health endpoint.

/// Implementations live in `data/repositories/` and must convert raw
/// infrastructure failures into [AppResult] failures using the shared
/// `AppException` taxonomy.
abstract class HealthRepository {
  Future<AppResult<BackendHealth>> checkBackendHealth();
}
