import '../../core/result/app_result.dart';
import '../models/paginated_products.dart';
import '../models/product.dart';
import '../models/product_list_query.dart';
import '../models/product_mutations.dart';

/// Domain contract for the product catalog backend operations.
abstract class ProductRepository {
  Future<AppResult<PaginatedProducts>> listProducts(ProductListQuery query);

  Future<AppResult<Product>> getProduct(String productId);

  Future<AppResult<Product>> createProduct(CreateProductInput input);

  Future<AppResult<Product>> updateProduct(
    String productId,
    UpdateProductInput input,
  );

  Future<AppResult<void>> deactivateProduct(String productId);
}
