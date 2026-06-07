import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../core/storage/auth_token_storage.dart';
import '../../domain/models/branch.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../navigation/app_session.dart';
import '../datasources/rest/rest_api_branch_data_source.dart';
import '../repositories/branch_repository_impl.dart';
import 'auth_providers.dart';

final branchDataSourceProvider = Provider<RestApiBranchDataSource>(
  (ref) => RestApiBranchDataSource(ref.watch(authenticatedDioProvider)),
);

final branchRepositoryProvider = Provider<BranchRepository>(
  (ref) => BranchRepositoryImpl(ref.watch(branchDataSourceProvider)),
);

final branchSessionHandlerProvider = Provider<BranchSessionHandler>(
  (ref) => BranchSessionHandler(
    ref.watch(tokenStorageProvider),
    ref.watch(appSessionProvider),
  ),
);

final branchesProvider = FutureProvider<AppResult<List<Branch>>>(
  (ref) => _loadBranches(ref, isActive: true),
);

final inactiveBranchesProvider = FutureProvider<AppResult<List<Branch>>>(
  (ref) => _loadBranches(ref, isActive: false),
);

final allBranchesProvider = FutureProvider<AppResult<List<Branch>>>((
  ref,
) async {
  final repository = ref.watch(branchRepositoryProvider);
  final sessionHandler = ref.watch(branchSessionHandlerProvider);
  final results = await Future.wait([
    repository.getBranches(isActive: true),
    repository.getBranches(isActive: false),
  ]);

  for (final result in results) {
    final exception = result.exceptionOrNull;
    if (exception != null) {
      await sessionHandler.handle(exception);
      return AppFailure(exception);
    }
  }

  final branchesById = <String, Branch>{};
  for (final result in results) {
    for (final branch in result.dataOrNull ?? const <Branch>[]) {
      branchesById[branch.id] = branch;
    }
  }

  return AppSuccess(branchesById.values.toList(growable: false));
});

Future<AppResult<List<Branch>>> _loadBranches(
  Ref ref, {
  required bool isActive,
}) async {
  final repository = ref.watch(branchRepositoryProvider);
  final sessionHandler = ref.watch(branchSessionHandlerProvider);
  final result = await repository.getBranches(isActive: isActive);
  await sessionHandler.handle(result.exceptionOrNull);
  return result;
}

final class BranchSessionHandler {
  const BranchSessionHandler(this._tokenStorage, this._appSession);

  final AuthTokenStorage _tokenStorage;
  final AppSession _appSession;

  Future<void> handle(AppException? exception) async {
    if (exception?.code != AppErrorCode.unauthorized) {
      return;
    }
    await _tokenStorage.clear();
    _appSession.signOut();
  }
}

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

  void clear() {
    state = null;
  }
}
