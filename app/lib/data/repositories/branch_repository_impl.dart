import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/rest/rest_api_branch_data_source.dart';
import '../mappers/branch_mapper.dart';

final class BranchRepositoryImpl implements BranchRepository {
  const BranchRepositoryImpl(this._dataSource);

  final RestApiBranchDataSource _dataSource;

  @override
  Future<AppResult<List<Branch>>> getBranches() async {
    try {
      final dtos = await _dataSource.getBranches();
      return AppSuccess(
        dtos.map(BranchMapper.toDomain).toList(growable: false),
      );
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading branches.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
