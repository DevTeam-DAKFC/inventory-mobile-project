import '../../core/result/app_result.dart';
import '../models/stock_overview_item.dart';

/// Contract for read-only stock overview data.
abstract class StockRepository {
  Future<AppResult<List<StockOverviewItem>>> getStockByBranch(String branchId);
}
