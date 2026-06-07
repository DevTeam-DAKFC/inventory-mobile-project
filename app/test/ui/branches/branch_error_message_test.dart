import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/ui/branches/branch_error_message.dart';

void main() {
  test('maps branch failures to friendly messages', () {
    const cases = <AppErrorCode, String>{
      AppErrorCode.validationError: 'Revisa la información ingresada.',
      AppErrorCode.unauthorized: 'Tu sesión expiró. Inicia sesión nuevamente.',
      AppErrorCode.forbidden: 'No tienes permisos para realizar esta acción.',
      AppErrorCode.notFound: 'La sucursal ya no existe.',
      AppErrorCode.networkError: 'No fue posible conectar con el servidor.',
      AppErrorCode.timeout: 'No fue posible conectar con el servidor.',
      AppErrorCode.unexpected:
          'Ocurrió un error inesperado. Inténtalo nuevamente.',
    };

    for (final entry in cases.entries) {
      expect(
        branchErrorMessage(
          AppException(code: entry.key, message: 'technical detail'),
        ),
        entry.value,
      );
    }
  });

  test('shows the backend message for a business conflict', () {
    const exception = AppException(
      code: AppErrorCode.conflict,
      message: 'Ya existe una sucursal con ese nombre.',
    );

    expect(
      branchErrorMessage(exception),
      'Ya existe una sucursal con ese nombre.',
    );
  });
}
