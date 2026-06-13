import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/backend_health_rest_dto.dart';

void main() {
  group('BackendHealthRestDto', () {
    test('parses valid JSON', () {
      final dto = BackendHealthRestDto.fromJson(<String, dynamic>{
        'status': 'ok',
        'service': 'Inventory.Api',
      });

      expect(dto.status, 'ok');
      expect(dto.service, 'Inventory.Api');
    });

    test('serializes to JSON', () {
      const dto = BackendHealthRestDto(status: 'ok', service: 'Inventory.Api');

      expect(dto.toJson(), <String, dynamic>{
        'status': 'ok',
        'service': 'Inventory.Api',
      });
    });

    test('throws AppException with code unexpected when status is missing', () {
      expect(
        () => BackendHealthRestDto.fromJson(<String, dynamic>{
          'service': 'Inventory.Api',
        }),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });

    test(
      'throws AppException with code unexpected when service is missing',
      () {
        expect(
          () =>
              BackendHealthRestDto.fromJson(<String, dynamic>{'status': 'ok'}),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              AppErrorCode.unexpected,
            ),
          ),
        );
      },
    );

    test('throws AppException when status is not a string', () {
      expect(
        () => BackendHealthRestDto.fromJson(<String, dynamic>{
          'status': 1,
          'service': 'Inventory.Api',
        }),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });

    test('throws AppException when service is not a string', () {
      expect(
        () => BackendHealthRestDto.fromJson(<String, dynamic>{
          'status': 'ok',
          'service': 42,
        }),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });
  });
}
