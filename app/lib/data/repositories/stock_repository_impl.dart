import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/stock_overview_item.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/rest/rest_api_stock_data_source.dart';
import '../mappers/stock_overview_mapper.dart';

final class StockRepositoryImpl implements StockRepository {
  const StockRepositoryImpl(this._dataSource);

  final RestApiStockDataSource _dataSource;

  @override
  Future<AppResult<List<StockOverviewItem>>> getStockByBranch(
    String branchId,
  ) async {
    try {
      final dtos = await _dataSource.fetchStockByBranch(branchId);
      return AppSuccess(
        dtos.map(StockOverviewMapper.toDomain).toList(growable: false),
      );
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading stock.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
