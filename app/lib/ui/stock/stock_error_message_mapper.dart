import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';

final class StockErrorMessageMapper {
  const StockErrorMessageMapper._();

  static String fromException(AppException exception) {
    final statusCode = exception.details?['statusCode'];

    if (statusCode is int) {
      return switch (statusCode) {
        400 => 'No fue posible consultar el stock solicitado.',
        401 => 'Tu sesión expiró. Inicia sesión nuevamente.',
        403 => 'No tienes permisos para consultar el stock.',
        404 => 'No se encontró información de stock para esta sucursal.',
        409 => 'No fue posible consultar el stock en este momento.',
        500 => 'Ocurrió un error interno. Inténtalo más tarde.',
        503 => 'El servicio no está disponible. Inténtalo más tarde.',
        _ => 'No fue posible cargar las existencias. Inténtalo nuevamente.',
      };
    }

    return switch (exception.code) {
      AppErrorCode.networkError ||
      AppErrorCode.timeout => 'No fue posible conectar con el servidor.',
      AppErrorCode.validationError =>
        'No fue posible consultar el stock solicitado.',
      AppErrorCode.unauthorized =>
        'Tu sesión expiró. Inicia sesión nuevamente.',
      AppErrorCode.forbidden => 'No tienes permisos para consultar el stock.',
      AppErrorCode.notFound =>
        'No se encontró información de stock para esta sucursal.',
      AppErrorCode.conflict =>
        'No fue posible consultar el stock en este momento.',
      AppErrorCode.serviceUnavailable =>
        'El servicio no está disponible. Inténtalo más tarde.',
      _ => 'No fue posible cargar las existencias. Inténtalo nuevamente.',
    };
  }
}
