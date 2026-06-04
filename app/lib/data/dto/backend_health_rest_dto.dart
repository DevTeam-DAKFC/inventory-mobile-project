import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

/// Wire-level representation of the `GET /health` response from the inventory
/// backend. Lives in the data layer so the domain model stays free of JSON.
final class BackendHealthRestDto {
  const BackendHealthRestDto({
    required this.status,
    required this.service,
  });

  final String status;
  final String service;

  factory BackendHealthRestDto.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final service = json['service'];
    if (status is! String) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid health response: field "status" is missing or not a string.',
        details: {'received': json},
      );
    }
    if (service is! String) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid health response: field "service" is missing or not a string.',
        details: {'received': json},
      );
    }
    return BackendHealthRestDto(status: status, service: service);
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'service': service,
      };
}
