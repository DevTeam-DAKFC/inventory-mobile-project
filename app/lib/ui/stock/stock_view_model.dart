import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/stock_config.dart';
import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../data/providers/stock_providers.dart';
import '../../domain/models/stock_overview_item.dart';
import 'stock_error_message_mapper.dart';
import 'stock_state.dart';

final stockViewModelProvider =
    AsyncNotifierProvider<StockViewModel, StockState>(StockViewModel.new);

class StockViewModel extends AsyncNotifier<StockState> {
  StockBranchOption _selectedBranch = StockConfig.defaultDevelopmentBranch;
  int _requestSequence = 0;

  @override
  StockState build() {
    final branch = _selectedBranch;
    unawaited(_loadSelectedBranch(branch));
    return StockLoading(branchId: branch.id, branchName: branch.name);
  }

  Future<void> refresh() async {
    await _loadSelectedBranch(_selectedBranch);
  }

  Future<void> selectBranch(String branchId) async {
    final nextBranch = StockConfig.developmentBranchById(branchId);
    if (nextBranch.id == _selectedBranch.id) {
      return;
    }

    _selectedBranch = nextBranch;
    await _loadSelectedBranch(nextBranch);
  }

  Future<void> _loadSelectedBranch(StockBranchOption branch) async {
    final requestId = ++_requestSequence;
    state = AsyncData(
      StockLoading(branchId: branch.id, branchName: branch.name),
    );

    final repository = ref.read(stockRepositoryProvider);
    final result = await repository.getStockByBranch(branch.id).catchError((
      Object error,
      StackTrace stack,
    ) {
      return AppFailure<List<StockOverviewItem>>(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading stock.',
          cause: error,
          stackTrace: stack,
        ),
      );
    });

    if (!_isCurrentRequest(requestId, branch.id)) {
      return;
    }

    final nextState = result.when(
      success: (items) => _successState(branch, items),
      failure: (exception) => StockError(
        branchId: branch.id,
        branchName: branch.name,
        message: StockErrorMessageMapper.fromException(exception),
        code: exception.code.value,
        technicalMessage: exception.message,
      ),
    );

    if (_isCurrentRequest(requestId, branch.id)) {
      state = AsyncData(nextState);
    }
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

  bool _isCurrentRequest(int requestId, String branchId) {
    return requestId == _requestSequence && branchId == _selectedBranch.id;
  }
}
