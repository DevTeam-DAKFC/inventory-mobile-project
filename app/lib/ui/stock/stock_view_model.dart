import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/stock_config.dart';
import '../../data/providers/stock_providers.dart';
import '../../domain/models/stock_overview_item.dart';
import 'stock_state.dart';

final stockViewModelProvider =
    AsyncNotifierProvider<StockViewModel, StockState>(StockViewModel.new);

class StockViewModel extends AsyncNotifier<StockState> {
  StockBranchOption _selectedBranch = StockConfig.defaultDevelopmentBranch;

  @override
  Future<StockState> build() => _loadStock(_selectedBranch);

  Future<void> refresh() async {
    state = AsyncData(
      StockLoading(
        branchId: _selectedBranch.id,
        branchName: _selectedBranch.name,
      ),
    );
    state = await AsyncValue.guard(() => _loadStock(_selectedBranch));
  }

  Future<void> selectBranch(String branchId) async {
    final nextBranch = StockConfig.developmentBranchById(branchId);
    if (nextBranch.id == _selectedBranch.id) {
      return;
    }

    _selectedBranch = nextBranch;
    state = AsyncData(
      StockLoading(branchId: nextBranch.id, branchName: nextBranch.name),
    );
    state = await AsyncValue.guard(() => _loadStock(nextBranch));
  }

  Future<StockState> _loadStock(StockBranchOption branch) async {
    final repository = ref.watch(stockRepositoryProvider);
    final result = await repository.getStockByBranch(branch.id);

    return result.when(
      success: (items) => _successState(branch, items),
      failure: (exception) => StockError(
        branchId: branch.id,
        branchName: branch.name,
        message: exception.message,
        code: exception.code.value,
      ),
    );
  }

  StockState _successState(
    StockBranchOption branch,
    List<StockOverviewItem> items,
  ) {
    if (items.isEmpty) {
      return StockEmpty(branchId: branch.id, branchName: branch.name);
    }

    final branchName = items.first.branchName.isEmpty
        ? branch.name
        : items.first.branchName;

    return StockLoaded(
      branchId: branch.id,
      branchName: branchName,
      items: items,
    );
  }
}
