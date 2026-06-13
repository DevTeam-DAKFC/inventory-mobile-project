import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/stock_lookup.dart';
import '../../domain/repositories/stock_lookup_repository.dart';
import '../datasources/rest/rest_api_stock_lookup_data_source.dart';
import '../mappers/stock_lookup_mapper.dart';

final class StockLookupRepositoryImpl implements StockLookupRepository {
  const StockLookupRepositoryImpl(this._dataSource);

  final RestApiStockLookupDataSource _dataSource;

  @override
  Future<AppResult<StockLookup>> getStockLookup({
    required String productId,
    required String branchId,
  }) async {
    try {
      final dto = await _dataSource.getStockLookup(
        productId: productId,
        branchId: branchId,
      );
      return AppSuccess(StockLookupMapper.toDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading stock lookup.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
