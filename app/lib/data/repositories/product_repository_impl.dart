import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/paginated_products.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_list_query.dart';
import '../../domain/models/product_mutations.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/rest/rest_api_product_data_source.dart';
import '../dto/product_requests.dart';
import '../mappers/product_mapper.dart';

/// Default ProductRepository backed by the inventory REST API.
final class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._dataSource);

  final RestApiProductDataSource _dataSource;

  @override
  Future<AppResult<PaginatedProducts>> listProducts(
    ProductListQuery query,
  ) async {
    return _guard(
      () async =>
          ProductMapper.pageToDomain(await _dataSource.listProducts(query)),
    );
  }

  @override
  Future<AppResult<Product>> getProduct(String productId) async {
    return _guard(
      () async =>
          ProductMapper.toDomain(await _dataSource.getProduct(productId)),
    );
  }

  @override
  Future<AppResult<Product>> createProduct(CreateProductInput input) async {
    return _guard(
      () async => ProductMapper.toDomain(
        await _dataSource.createProduct(ProductCreateRequest.fromInput(input)),
      ),
    );
  }

  @override
  Future<AppResult<Product>> updateProduct(
    String productId,
    UpdateProductInput input,
  ) async {
    return _guard(
      () async => ProductMapper.toDomain(
        await _dataSource.updateProduct(productId, ProductUpdateRequest(input)),
      ),
    );
  }

  @override
  Future<AppResult<void>> deactivateProduct(String productId) {
    return _guard(() => _dataSource.deactivateProduct(productId));
  }

  Future<AppResult<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return AppSuccess(await operation());
    } on AppException catch (error) {
      return AppFailure(error);
    } catch (error, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected product repository error.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }
}
