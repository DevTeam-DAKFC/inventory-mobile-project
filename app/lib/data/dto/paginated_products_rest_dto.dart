import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import 'product_rest_dto.dart';

/// Wire-level representation of the paginated `GET /products` response.
final class PaginatedProductsRestDto {
  const PaginatedProductsRestDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasNextPage,
  });

  final List<ProductRestDto> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasNextPage;

  factory PaginatedProductsRestDto.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final total = json['total'];
    final page = json['page'];
    final pageSize = json['pageSize'];
    final hasNextPage = json['hasNextPage'];

    if (items is! List ||
        total is! int ||
        total < 0 ||
        page is! int ||
        page < 1 ||
        pageSize is! int ||
        pageSize < 1 ||
        hasNextPage is! bool) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid paginated products response.',
        details: {'received': json},
      );
    }

    try {
      return PaginatedProductsRestDto(
        items: items
            .map(
              (item) => ProductRestDto.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(growable: false),
        total: total,
        page: page,
        pageSize: pageSize,
        hasNextPage: hasNextPage,
      );
    } on AppException {
      rethrow;
    } catch (error, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid product item in paginated response.',
        cause: error,
        stackTrace: stack,
        details: {'received': json},
      );
    }
  }
}
