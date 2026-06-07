import '../../core/result/app_result.dart';
import '../models/branch.dart';

abstract class BranchRepository {
  Future<AppResult<List<Branch>>> getBranches();
}
