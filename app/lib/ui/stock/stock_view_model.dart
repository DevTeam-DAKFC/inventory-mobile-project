import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/stock_config.dart';
import '../../data/providers/stock_providers.dart';
import '../../domain/models/stock_overview_item.dart';
import 'stock_state.dart';

final stockViewModelProvider =
    AsyncNotifierProvider<StockViewModel, StockState>(StockViewModel.new);

class StockViewModel extends AsyncNotifier<StockState> {
  static const _branchId = StockConfig.developmentBranchId;
  static const _branchName = StockConfig.developmentBranchName;

  @override
  Future<StockState> build() => _loadStock();

  Future<void> refresh() async {
    state = const AsyncLoading<StockState>();
    state = await AsyncValue.guard(_loadStock);
  }

  Future<StockState> _loadStock() async {
    final repository = ref.watch(stockRepositoryProvider);
    final result = await repository.getStockByBranch(_branchId);

    return result.when(
      success: (items) => _successState(items),
      failure: (exception) => StockError(
        branchId: _branchId,
        branchName: _branchName,
        message: exception.message,
        code: exception.code.value,
      ),
    );
  }

  StockState _successState(List<StockOverviewItem> items) {
    if (items.isEmpty) {
      return const StockEmpty(branchId: _branchId, branchName: _branchName);
    }

    final branchName = items.first.branchName.isEmpty
        ? _branchName
        : items.first.branchName;

    return StockLoaded(
      branchId: _branchId,
      branchName: branchName,
      items: items,
    );
  }
}
