import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_branch_data_source.dart';
import 'package:inventory_mobile/data/dto/branch_rest_dto.dart';
import 'package:inventory_mobile/data/dto/branch_write_request_dto.dart';
import 'package:inventory_mobile/data/repositories/branch_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockBranchDataSource extends Mock implements RestApiBranchDataSource {}

void main() {
  late _MockBranchDataSource dataSource;
  late BranchRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(const BranchWriteRequestDto(name: 'Sucursal'));
  });

  setUp(() {
    dataSource = _MockBranchDataSource();
    sut = BranchRepositoryImpl(dataSource);
  });

  group('getBranches', () {
    test('returns AppSuccess with mapped domain branches', () async {
      when(() => dataSource.getBranches()).thenAnswer(
        (_) async => const [
          BranchRestDto(
            id: '1',
            name: 'Sucursal Central',
            address: 'San Jose centro',
            isActive: true,
          ),
        ],
      );

      final result = await sut.getBranches();

      expect(result, isA<AppSuccess>());
      expect(result.dataOrNull, hasLength(1));
      expect(result.dataOrNull!.single.name, 'Sucursal Central');
    });

    test('returns AppFailure when data source throws AppException', () async {
      when(() => dataSource.getBranches()).thenThrow(
        const AppException(
          code: AppErrorCode.networkError,
          message: 'Could not load branches.',
        ),
      );

      final result = await sut.getBranches();

      expect(result, isA<AppFailure>());
      expect(result.exceptionOrNull!.code, AppErrorCode.networkError);
    });
  });

  group('createBranch', () {
    test('returns AppSuccess with created branch', () async {
      when(() => dataSource.createBranch(any())).thenAnswer(
        (_) async => const BranchRestDto(
          id: '1',
          name: 'Sucursal Central',
          address: 'San Jose centro',
          isActive: true,
        ),
      );

      final result = await sut.createBranch(
        name: 'Sucursal Central',
        address: 'San Jose centro',
      );

      expect(result, isA<AppSuccess>());
      expect(result.dataOrNull!.name, 'Sucursal Central');
    });
  });

  group('updateBranch', () {
    test('returns AppFailure when data source throws AppException', () async {
      when(() => dataSource.updateBranch(any(), any())).thenThrow(
        const AppException(code: AppErrorCode.forbidden, message: 'Forbidden.'),
      );

      final result = await sut.updateBranch(
        branchId: '1',
        name: 'Sucursal Norte',
      );

      expect(result, isA<AppFailure>());
      expect(result.exceptionOrNull!.code, AppErrorCode.forbidden);
    });
  });

  group('deactivateBranch', () {
    test('returns AppSuccess with deactivated branch', () async {
      when(() => dataSource.deactivateBranch('1')).thenAnswer(
        (_) async => const BranchRestDto(
          id: '1',
          name: 'Sucursal Central',
          isActive: false,
        ),
      );

      final result = await sut.deactivateBranch('1');

      expect(result, isA<AppSuccess>());
      expect(result, isA<AppSuccess<void>>());
    });
  });

  group('reactivateBranch', () {
    test('returns AppSuccess with reactivated branch', () async {
      when(() => dataSource.reactivateBranch('1')).thenAnswer(
        (_) async => const BranchRestDto(
          id: '1',
          name: 'Sucursal Central',
          isActive: true,
        ),
      );

      final result = await sut.reactivateBranch('1');

      expect(result, isA<AppSuccess>());
      expect(result, isA<AppSuccess<void>>());
    });
  });
}
