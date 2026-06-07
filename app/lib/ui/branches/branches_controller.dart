import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../data/providers/branch_providers.dart';
import '../../domain/models/branch.dart';

enum BranchFilter { all, active, inactive }

class BranchesController extends Notifier<BranchFilter> {
  @override
  BranchFilter build() => BranchFilter.active;

  void selectFilter(BranchFilter filter) {
    state = filter;
  }

  Future<AppResult<Branch>> saveBranch({
    Branch? branch,
    required String name,
    String? address,
  }) async {
    final repository = ref.read(branchRepositoryProvider);
    final result = branch == null
        ? await repository.createBranch(name: name, address: address)
        : await repository.updateBranch(
            branchId: branch.id,
            name: name,
            address: address,
          );
    await handleException(result.exceptionOrNull);
    if (result.isSuccess) {
      refreshAll();
    }
    return result;
  }

  Future<AppResult<void>> deactivate(Branch branch) async {
    final result = await ref
        .read(branchRepositoryProvider)
        .deactivateBranch(branch.id);

    await handleException(result.exceptionOrNull);
    if (result.isSuccess) {
      if (ref.read(selectedBranchProvider)?.id == branch.id) {
        ref.read(selectedBranchProvider.notifier).clear();
      }
      refreshAll();
    }

    return result;
  }

  Future<AppResult<void>> reactivate(Branch branch) async {
    final result = await ref
        .read(branchRepositoryProvider)
        .reactivateBranch(branch.id);

    await handleException(result.exceptionOrNull);
    if (result.isSuccess) {
      state = BranchFilter.active;
      refreshAll();
    }

    return result;
  }

  Future<void> handleException(AppException? exception) =>
      ref.read(branchSessionHandlerProvider).handle(exception);

  void refreshCurrent() {
    switch (state) {
      case BranchFilter.all:
        ref.invalidate(allBranchesProvider);
      case BranchFilter.active:
        ref.invalidate(branchesProvider);
      case BranchFilter.inactive:
        ref.invalidate(inactiveBranchesProvider);
    }
  }

  void refreshAll() {
    ref.invalidate(allBranchesProvider);
    ref.invalidate(branchesProvider);
    ref.invalidate(inactiveBranchesProvider);
  }
}

final branchesControllerProvider =
    NotifierProvider.autoDispose<BranchesController, BranchFilter>(
      BranchesController.new,
    );
