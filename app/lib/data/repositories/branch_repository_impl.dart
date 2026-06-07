import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/rest/rest_api_branch_data_source.dart';
import '../dto/branch_rest_dto.dart';
import '../dto/branch_write_request_dto.dart';
import '../mappers/branch_mapper.dart';

final class BranchRepositoryImpl implements BranchRepository {
  const BranchRepositoryImpl(this._dataSource);

  final RestApiBranchDataSource _dataSource;

  @override
  Future<AppResult<List<Branch>>> getBranches({bool? isActive}) async {
    try {
      final dtos = await _dataSource.getBranches(isActive: isActive);
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

  @override
  Future<AppResult<Branch>> createBranch({
    required String name,
    String? address,
  }) async {
    return _writeBranch(
      operation: () => _dataSource.createBranch(
        BranchWriteRequestDto(name: name, address: address),
      ),
      unexpectedMessage: 'Unexpected error creating branch.',
    );
  }

  @override
  Future<AppResult<Branch>> updateBranch({
    required String branchId,
    required String name,
    String? address,
  }) async {
    return _writeBranch(
      operation: () => _dataSource.updateBranch(
        branchId,
        BranchWriteRequestDto(name: name, address: address),
      ),
      unexpectedMessage: 'Unexpected error updating branch.',
    );
  }

  @override
  Future<AppResult<void>> deactivateBranch(String branchId) async {
    return _writeStatus(
      operation: () => _dataSource.deactivateBranch(branchId),
      unexpectedMessage: 'Unexpected error deactivating branch.',
    );
  }

  @override
  Future<AppResult<void>> reactivateBranch(String branchId) async {
    return _writeStatus(
      operation: () => _dataSource.reactivateBranch(branchId),
      unexpectedMessage: 'Unexpected error reactivating branch.',
    );
  }

  Future<AppResult<void>> _writeStatus({
    required Future<Object?> Function() operation,
    required String unexpectedMessage,
  }) async {
    try {
      await operation();
      return const AppSuccess(null);
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: unexpectedMessage,
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<AppResult<Branch>> _writeBranch({
    required Future<BranchRestDto> Function() operation,
    required String unexpectedMessage,
  }) async {
    try {
      final dto = await operation();
      return AppSuccess(BranchMapper.toDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: unexpectedMessage,
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
