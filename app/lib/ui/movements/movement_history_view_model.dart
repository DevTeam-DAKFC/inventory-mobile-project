import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/inventory_movement_providers.dart';
import '../../domain/models/inventory_movement_filters.dart';
import 'movement_history_state.dart';

final movementHistoryViewModelProvider =
    NotifierProvider<MovementHistoryViewModel, MovementHistoryState>(
      MovementHistoryViewModel.new,
    );

class MovementHistoryViewModel extends Notifier<MovementHistoryState> {
  @override
  MovementHistoryState build() => const MovementHistoryState();

  Future<void> load({InventoryMovementFilters? filters}) async {
    final nextFilters = filters ?? state.filters;
    state = state.copyWith(
      filters: nextFilters,
      isLoading: true,
      clearError: true,
    );

    final result = await ref
        .read(inventoryMovementRepositoryProvider)
        .getMovements(nextFilters);

    result.when(
      success: (page) {
        state = state.copyWith(
          movements: page.items,
          totalCount: page.totalCount,
          isLoading: false,
          hasLoaded: true,
          clearError: true,
        );
      },
      failure: (exception) {
        state = state.copyWith(
          isLoading: false,
          hasLoaded: true,
          errorCode: exception.code,
          errorMessage: exception.message,
        );
      },
    );
  }

  Future<void> applyFilters(InventoryMovementFilters filters) {
    return load(filters: filters.copyWith(page: 1));
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasNextPage) return;
    final nextFilters = state.filters.copyWith(page: state.filters.page + 1);

    state = state.copyWith(isLoading: true, clearError: true);
    final result = await ref
        .read(inventoryMovementRepositoryProvider)
        .getMovements(nextFilters);

    result.when(
      success: (page) {
        state = state.copyWith(
          filters: nextFilters,
          movements: [...state.movements, ...page.items],
          totalCount: page.totalCount,
          isLoading: false,
          hasLoaded: true,
          clearError: true,
        );
      },
      failure: (exception) {
        state = state.copyWith(
          isLoading: false,
          errorCode: exception.code,
          errorMessage: exception.message,
        );
      },
    );
  }
}
