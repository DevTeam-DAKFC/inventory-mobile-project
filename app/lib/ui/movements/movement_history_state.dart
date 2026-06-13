import '../../core/errors/app_error_code.dart';
import '../../domain/models/inventory_movement.dart';
import '../../domain/models/inventory_movement_filters.dart';

final class MovementHistoryState {
  const MovementHistoryState({
    this.filters = const InventoryMovementFilters(),
    this.movements = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorCode,
    this.errorMessage,
  });

  final InventoryMovementFilters filters;
  final List<InventoryMovement> movements;
  final int totalCount;
  final bool isLoading;
  final bool hasLoaded;
  final AppErrorCode? errorCode;
  final String? errorMessage;

  bool get isEmpty => hasLoaded && movements.isEmpty && errorMessage == null;

  bool get hasNextPage => filters.page * filters.pageSize < totalCount;

  MovementHistoryState copyWith({
    InventoryMovementFilters? filters,
    List<InventoryMovement>? movements,
    int? totalCount,
    bool? isLoading,
    bool? hasLoaded,
    AppErrorCode? errorCode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MovementHistoryState(
      filters: filters ?? this.filters,
      movements: movements ?? this.movements,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
