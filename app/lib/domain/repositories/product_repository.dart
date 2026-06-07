import '../../core/result/app_result.dart';
import '../models/paginated_result.dart';
import '../models/product.dart';

abstract class ProductRepository {
  Future<AppResult<PaginatedResult<Product>>> getProducts({
    bool? isActive,
    int page = 1,
    int pageSize = 100,
  });

  Future<AppResult<void>> activateProduct(String productId);

  Future<AppResult<void>> deactivateProduct(String productId);
}
