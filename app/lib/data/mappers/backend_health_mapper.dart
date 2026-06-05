import '../../domain/models/backend_health.dart';
import '../dto/backend_health_rest_dto.dart';

/// Translates [BackendHealthRestDto] into the domain-level [BackendHealth].
final class BackendHealthMapper {
  const BackendHealthMapper._();

  static BackendHealth toDomain(BackendHealthRestDto dto) =>
      BackendHealth(status: dto.status, service: dto.service);
}
