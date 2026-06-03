import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';

void main() {
  group('AppSuccess', () {
    test('exposes data and reports isSuccess true', () {
      const result = AppSuccess<int>(42);

      expect(result.data, 42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('dataOrNull returns the value and exceptionOrNull returns null', () {
      const result = AppSuccess<String>('ok');

      expect(result.dataOrNull, 'ok');
      expect(result.exceptionOrNull, isNull);
    });

    test('when() runs the success branch with the held value', () {
      const result = AppSuccess<int>(5);

      final output = result.when(
        success: (data) => 'data=$data',
        failure: (_) => 'failure',
      );

      expect(output, 'data=5');
    });
  });

  group('AppFailure', () {
    const exception = AppException(
      code: AppErrorCode.notFound,
      message: 'missing',
    );

    test('exposes exception and reports isFailure true', () {
      const result = AppFailure<int>(exception);

      expect(result.exception, same(exception));
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('dataOrNull returns null and exceptionOrNull returns the exception',
        () {
      const result = AppFailure<int>(exception);

      expect(result.dataOrNull, isNull);
      expect(result.exceptionOrNull, same(exception));
    });

    test('when() runs the failure branch with the held exception', () {
      const result = AppFailure<int>(exception);

      final output = result.when(
        success: (_) => 'success',
        failure: (e) => 'failure=${e.code.value}',
      );

      expect(output, 'failure=not_found');
    });
  });
}
