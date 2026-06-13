import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_health_data_source.dart';
import 'package:inventory_mobile/data/dto/backend_health_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/health_repository_impl.dart';
import 'package:inventory_mobile/domain/models/backend_health.dart';
import 'package:mocktail/mocktail.dart';

class _MockHealthDataSource extends Mock implements RestApiHealthDataSource {}

void main() {
  late _MockHealthDataSource dataSource;
  late HealthRepositoryImpl sut;

  setUp(() {
    dataSource = _MockHealthDataSource();
    sut = HealthRepositoryImpl(dataSource);
  });

  group('HealthRepositoryImpl.checkBackendHealth', () {
    test(
      'returns AppSuccess<BackendHealth> on a successful response',
      () async {
        when(() => dataSource.checkBackendHealth()).thenAnswer(
          (_) async => const BackendHealthRestDto(
            status: 'ok',
            service: 'Inventory.Api',
          ),
        );

        final result = await sut.checkBackendHealth();

        expect(result, isA<AppSuccess<BackendHealth>>());
      },
    );

    test('maps status and service correctly on success', () async {
      when(() => dataSource.checkBackendHealth()).thenAnswer(
        (_) async =>
            const BackendHealthRestDto(status: 'ok', service: 'Inventory.Api'),
      );

      final result = await sut.checkBackendHealth();
      final data = result.dataOrNull;

      expect(data, isNotNull);
      expect(data!.status, 'ok');
      expect(data.service, 'Inventory.Api');
      expect(data.isOk, isTrue);
    });

    test(
      'returns AppFailure preserving the AppException thrown by the source',
      () async {
        const exception = AppException(
          code: AppErrorCode.unexpected,
          message: 'malformed health payload',
        );
        when(() => dataSource.checkBackendHealth()).thenThrow(exception);

        final result = await sut.checkBackendHealth();

        expect(result, isA<AppFailure<BackendHealth>>());
        expect(result.exceptionOrNull, same(exception));
      },
    );

    test(
      'returns AppFailure with code timeout when the source times out',
      () async {
        const exception = AppException(
          code: AppErrorCode.timeout,
          message: 'timed out',
        );
        when(() => dataSource.checkBackendHealth()).thenThrow(exception);

        final result = await sut.checkBackendHealth();

        expect(result.exceptionOrNull?.code, AppErrorCode.timeout);
      },
    );

    test('returns AppFailure with code serviceUnavailable when the source '
        'reports 503', () async {
      const exception = AppException(
        code: AppErrorCode.serviceUnavailable,
        message: 'backend unavailable',
      );
      when(() => dataSource.checkBackendHealth()).thenThrow(exception);

      final result = await sut.checkBackendHealth();

      expect(result.exceptionOrNull?.code, AppErrorCode.serviceUnavailable);
    });

    test('returns AppFailure with code networkError when the source reports '
        'a network failure', () async {
      const exception = AppException(
        code: AppErrorCode.networkError,
        message: 'no network',
      );
      when(() => dataSource.checkBackendHealth()).thenThrow(exception);

      final result = await sut.checkBackendHealth();

      expect(result.exceptionOrNull?.code, AppErrorCode.networkError);
    });

    test('returns AppFailure with code unexpected when the source throws a '
        'non-AppException error', () async {
      when(() => dataSource.checkBackendHealth()).thenThrow(StateError('boom'));

      final result = await sut.checkBackendHealth();

      expect(result, isA<AppFailure<BackendHealth>>());
      expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
      expect(result.exceptionOrNull?.cause, isA<StateError>());
    });
  });
}
