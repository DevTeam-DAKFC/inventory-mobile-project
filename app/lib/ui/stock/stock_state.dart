import '../../domain/models/stock_overview_item.dart';

sealed class StockState {
  const StockState();
}

final class StockLoaded extends StockState {
  const StockLoaded({
    required this.branchId,
    required this.branchName,
    required this.items,
  });

  final String branchId;
  final String branchName;
  final List<StockOverviewItem> items;
}

final class StockEmpty extends StockState {
  const StockEmpty({required this.branchId, required this.branchName});

  final String branchId;
  final String branchName;
}

final class StockError extends StockState {
  const StockError({
    required this.branchId,
    required this.branchName,
    required this.message,
    required this.code,
  });

  final String branchId;
  final String branchName;
  final String message;
  final String code;
}
