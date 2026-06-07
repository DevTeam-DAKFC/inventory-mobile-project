import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/paginated_result.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/rest/rest_api_product_data_source.dart';
import '../mappers/product_mapper.dart';

final class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._dataSource);

  final RestApiProductDataSource _dataSource;

  @override
  Future<AppResult<PaginatedResult<Product>>> getProducts({
    bool? isActive,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final dto = await _dataSource.getProducts(
        isActive: isActive,
        page: page,
        pageSize: pageSize,
      );
      return AppSuccess(ProductMapper.toPaginatedDomain(dto));
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected error loading products.',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<AppResult<void>> activateProduct(String productId) async {
    return _changeProductState(
      productId,
      action: _dataSource.activateProduct,
      unexpectedMessage: 'Unexpected error activating product.',
    );
  }

  @override
  Future<AppResult<void>> deactivateProduct(String productId) async {
    return _changeProductState(
      productId,
      action: _dataSource.deactivateProduct,
      unexpectedMessage: 'Unexpected error deactivating product.',
    );
  }

  Future<AppResult<void>> _changeProductState(
    String productId, {
    required Future<void> Function(String productId) action,
    required String unexpectedMessage,
  }) async {
    try {
      await action(productId);
      return const AppSuccess(null);
    } on AppException catch (e) {
      return AppFailure(e);
    } catch (e, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: unexpectedMessage,
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }
}
