import 'app_error_code.dart';

/// Controlled exception type for the application.
///
/// Repositories and data sources map raw infrastructure errors (Firestore,
/// Dio, file system, etc.) into this shape so the upper layers always
/// observe a stable, finite error surface.
class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    this.cause,
    this.stackTrace,
    this.details,
  });

  final AppErrorCode code;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  final Map<String, Object?>? details;

  @override
  String toString() => 'AppException(${code.value}): $message';
}
