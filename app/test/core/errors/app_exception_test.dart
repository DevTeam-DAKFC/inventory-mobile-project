import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';

void main() {
  group('AppErrorCode.value', () {
    test('returns API-style snake_case for the expected codes', () {
      expect(AppErrorCode.validationError.value, 'validation_error');
      expect(AppErrorCode.unauthorized.value, 'unauthorized');
      expect(AppErrorCode.forbidden.value, 'forbidden');
      expect(AppErrorCode.notFound.value, 'not_found');
      expect(AppErrorCode.conflict.value, 'conflict');
      expect(AppErrorCode.insufficientStock.value, 'insufficient_stock');
      expect(AppErrorCode.inactiveProduct.value, 'inactive_product');
      expect(AppErrorCode.inactiveBranch.value, 'inactive_branch');
      expect(AppErrorCode.productNotFound.value, 'product_not_found');
      expect(AppErrorCode.serviceUnavailable.value, 'service_unavailable');
      expect(
        AppErrorCode.uploadSessionExpired.value,
        'upload_session_expired',
      );
      expect(AppErrorCode.uploadNotCompleted.value, 'upload_not_completed');
      expect(AppErrorCode.networkError.value, 'network_error');
      expect(AppErrorCode.timeout.value, 'timeout');
      expect(AppErrorCode.unexpected.value, 'unexpected');
    });
  });

  group('AppException', () {
    test('toString includes the code value and message', () {
      const exception = AppException(
        code: AppErrorCode.insufficientStock,
        message: 'Stock too low',
      );

      expect(
        exception.toString(),
        'AppException(insufficient_stock): Stock too low',
      );
    });

    test('stores optional cause, stackTrace and details', () {
      final cause = StateError('underlying');
      final stack = StackTrace.current;
      const details = <String, Object?>{'field': 'quantity'};

      final exception = AppException(
        code: AppErrorCode.validationError,
        message: 'invalid',
        cause: cause,
        stackTrace: stack,
        details: details,
      );

      expect(exception.code, AppErrorCode.validationError);
      expect(exception.message, 'invalid');
      expect(exception.cause, same(cause));
      expect(exception.stackTrace, same(stack));
      expect(exception.details, details);
    });
  });
}
