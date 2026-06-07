import '../../core/result/app_result.dart';
import '../models/branch.dart';

abstract class BranchRepository {
  Future<AppResult<List<Branch>>> getBranches({bool? isActive});

  Future<AppResult<Branch>> createBranch({
    required String name,
    String? address,
  });

  Future<AppResult<Branch>> updateBranch({
    required String branchId,
    required String name,
    String? address,
  });

  Future<AppResult<void>> deactivateBranch(String branchId);

  Future<AppResult<void>> reactivateBranch(String branchId);
}
