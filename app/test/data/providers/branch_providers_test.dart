import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/core/storage/auth_token_storage.dart';
import 'package:inventory_mobile/data/providers/auth_providers.dart';
import 'package:inventory_mobile/data/providers/branch_providers.dart';
import 'package:inventory_mobile/domain/models/branch.dart';
import 'package:inventory_mobile/domain/repositories/branch_repository.dart';
import 'package:inventory_mobile/navigation/app_session.dart';

final class _FakeTokenStorage implements AuthTokenStorage {
  StoredAuthToken? token;
  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls += 1;
    token = null;
  }

  @override
  Future<StoredAuthToken?> readToken() async => token;

  @override
  Future<void> saveToken(StoredAuthToken token) async {
    this.token = token;
  }
}

final class _FakeBranchRepository implements BranchRepository {
  _FakeBranchRepository(this.loader);

  final Future<AppResult<List<Branch>>> Function(bool? isActive) loader;
  final List<bool?> requestedStatuses = [];

  @override
  Future<AppResult<List<Branch>>> getBranches({bool? isActive}) {
    requestedStatuses.add(isActive);
    return loader(isActive);
  }

  @override
  Future<AppResult<Branch>> createBranch({
    required String name,
    String? address,
  }) => throw UnimplementedError();

  @override
  Future<AppResult<void>> deactivateBranch(String branchId) =>
      throw UnimplementedError();

  @override
  Future<AppResult<void>> reactivateBranch(String branchId) =>
      throw UnimplementedError();

  @override
  Future<AppResult<Branch>> updateBranch({
    required String branchId,
    required String name,
    String? address,
  }) => throw UnimplementedError();
}

void main() {
  test(
    'allBranchesProvider combines statuses and removes duplicate ids',
    () async {
      final repository = _FakeBranchRepository(
        (isActive) async => AppSuccess([
          Branch(
            id: isActive == true ? '1' : '2',
            name: isActive == true ? 'Activa' : 'Inactiva',
            isActive: isActive!,
          ),
          const Branch(id: 'shared', name: 'Compartida', isActive: true),
        ]),
      );
      final container = ProviderContainer(
        overrides: [branchRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final result = await container.read(allBranchesProvider.future);

      expect(result.dataOrNull, hasLength(3));
      expect(repository.requestedStatuses, containsAll(<bool?>[true, false]));
    },
  );

  test('401 clears the token and signs out the current session', () async {
    final session = AppSession()..signInAsDemoAdmin();
    addTearDown(session.dispose);
    final storage = _FakeTokenStorage()
      ..token = StoredAuthToken(
        accessToken: 'expired',
        expiresAt: DateTime.utc(2099),
      );
    final repository = _FakeBranchRepository(
      (_) async => const AppFailure(
        AppException(
          code: AppErrorCode.unauthorized,
          message: 'expired session',
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        branchRepositoryProvider.overrideWithValue(repository),
        tokenStorageProvider.overrideWithValue(storage),
        appSessionProvider.overrideWithValue(session),
      ],
    );
    addTearDown(container.dispose);

    await container.read(branchesProvider.future);

    expect(storage.clearCalls, 1);
    expect(storage.token, isNull);
    expect(session.isAuthenticated, isFalse);
  });
}
