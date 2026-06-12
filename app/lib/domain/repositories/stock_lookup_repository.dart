import '../../core/result/app_result.dart';
import '../models/stock_lookup.dart';

abstract class StockLookupRepository {
  Future<AppResult<StockLookup>> getStockLookup({
    required String productId,
    required String branchId,
  });
}
