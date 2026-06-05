import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/models/product_list_query.dart';
import '../../dto/paginated_products_rest_dto.dart';
import '../../dto/product_requests.dart';
import '../../dto/product_rest_dto.dart';
import 'rest_error_parser.dart';

/// REST data source for the product catalog endpoints.
class RestApiProductDataSource {
  const RestApiProductDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedProductsRestDto> listProducts(ProductListQuery query) async {
    final response = await _request(
      () => _dio.get<dynamic>(
        '/products',
        queryParameters: _queryParameters(query),
      ),
    );
    return PaginatedProductsRestDto.fromJson(_jsonObject(response.data));
  }

  Future<ProductRestDto> getProduct(String productId) async {
    final response = await _request(
      () => _dio.get<dynamic>('/products/$productId'),
    );
    return ProductRestDto.fromJson(_jsonObject(response.data));
  }

  Future<ProductRestDto> createProduct(ProductCreateRequest request) async {
    final response = await _request(
      () => _dio.post<dynamic>('/products', data: request.toJson()),
    );
    return ProductRestDto.fromJson(_jsonObject(response.data));
  }

  Future<ProductRestDto> updateProduct(
    String productId,
    ProductUpdateRequest request,
  ) async {
    final response = await _request(
      () => _dio.patch<dynamic>('/products/$productId', data: request.toJson()),
    );
    return ProductRestDto.fromJson(_jsonObject(response.data));
  }

  Future<void> deactivateProduct(String productId) async {
    await _request(
      () => _dio.patch<dynamic>('/products/$productId/deactivate'),
    );
  }

  Map<String, dynamic> _queryParameters(ProductListQuery query) => {
    if (_hasText(query.q)) 'q': query.q!.trim(),
    if (_hasText(query.category)) 'category': query.category!.trim(),
    if (query.isActive != null) 'isActive': query.isActive,
    if (query.lowStockOnly != null) 'lowStockOnly': query.lowStockOnly,
    if (query.page != null) 'page': query.page,
    if (query.pageSize != null) 'pageSize': query.pageSize,
  };

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error, stack) {
      throw RestErrorParser.fromDio(error, stack);
    } on AppException {
      rethrow;
    } catch (error, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected product backend error.',
        cause: error,
        stackTrace: stack,
      );
    }
  }

  Map<String, dynamic> _jsonObject(dynamic data) {
    if (data is Map && data.keys.every((key) => key is String)) {
      return Map<String, dynamic>.from(data);
    }
    throw AppException(
      code: AppErrorCode.unexpected,
      message: 'Invalid product response: payload is not a JSON object.',
      details: {'received': data},
    );
  }
}
