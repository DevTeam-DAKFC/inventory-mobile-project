import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_branch_data_source.dart';
import 'package:inventory_mobile/data/dto/branch_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/branch_repository_impl.dart';
import 'package:inventory_mobile/domain/models/branch.dart';
import 'package:mocktail/mocktail.dart';

class _MockBranchDataSource extends Mock implements RestApiBranchDataSource {}

BranchRestDto _branchDto({bool isActive = true}) {
  return BranchRestDto(
    id: 'branch-id',
    name: 'Central Branch',
    address: 'Main street',
    isActive: isActive,
    createdAt: DateTime.utc(2026, 6, 5, 20),
  );
}

void main() {
  late _MockBranchDataSource dataSource;
  late BranchRepositoryImpl sut;

  setUp(() {
    dataSource = _MockBranchDataSource();
    sut = BranchRepositoryImpl(dataSource);
  });

  group('getBranches', () {
    test('returns AppSuccess with mapped branches', () async {
      when(
        () => dataSource.getBranches(),
      ).thenAnswer((_) async => [_branchDto()]);

      final result = await sut.getBranches();

      expect(result, isA<AppSuccess<List<Branch>>>());
      expect(result.dataOrNull?.single.name, 'Central Branch');
    });

    test('preserves AppException failures from the data source', () async {
      const exception = AppException(
        code: AppErrorCode.unauthorized,
        message: 'Unauthorized.',
      );
      when(() => dataSource.getBranches()).thenThrow(exception);

      final result = await sut.getBranches();

      expect(result, isA<AppFailure<List<Branch>>>());
      expect(result.exceptionOrNull, same(exception));
    });

    test('returns unexpected failure for non-AppException errors', () async {
      when(() => dataSource.getBranches()).thenThrow(StateError('boom'));

      final result = await sut.getBranches();

      expect(result, isA<AppFailure<List<Branch>>>());
      expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
    });
  });
}
