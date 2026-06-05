import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/app_result.dart';
import '../../domain/models/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../datasources/rest/rest_api_branch_data_source.dart';
import '../repositories/branch_repository_impl.dart';
import 'health_providers.dart';

final branchDataSourceProvider = Provider<RestApiBranchDataSource>(
  (ref) => RestApiBranchDataSource(ref.watch(apiClientProvider).dio),
);

final branchRepositoryProvider = Provider<BranchRepository>(
  (ref) => BranchRepositoryImpl(ref.watch(branchDataSourceProvider)),
);

final branchesProvider = FutureProvider<AppResult<List<Branch>>>(
  (ref) => ref.watch(branchRepositoryProvider).getBranches(),
);

final selectedBranchProvider =
    NotifierProvider<SelectedBranchNotifier, Branch?>(
      SelectedBranchNotifier.new,
    );

final class SelectedBranchNotifier extends Notifier<Branch?> {
  @override
  Branch? build() => null;

  void select(Branch branch) {
    state = branch;
  }
}
