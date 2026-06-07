import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

String branchErrorMessage(AppException exception) {
  return switch (exception.code) {
    AppErrorCode.validationError => 'Revisa la información ingresada.',
    AppErrorCode.unauthorized => 'Tu sesión expiró. Inicia sesión nuevamente.',
    AppErrorCode.forbidden => 'No tienes permisos para realizar esta acción.',
    AppErrorCode.notFound => 'La sucursal ya no existe.',
    AppErrorCode.conflict => _conflictMessage(exception),
    AppErrorCode.networkError ||
    AppErrorCode.timeout => 'No fue posible conectar con el servidor.',
    AppErrorCode.serviceUnavailable =>
      'El servicio no está disponible en este momento.',
    _ => 'Ocurrió un error inesperado. Inténtalo nuevamente.',
  };
}

String _conflictMessage(AppException exception) {
  final message = exception.message.trim();
  if (message.isEmpty || message.startsWith('Backend returned status')) {
    return 'La operación entra en conflicto con los datos existentes.';
  }
  return message;
}
