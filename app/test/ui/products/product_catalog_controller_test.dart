import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/product_providers.dart';
import 'package:inventory_mobile/domain/models/paginated_products.dart';
import 'package:inventory_mobile/domain/models/product.dart';
import 'package:inventory_mobile/domain/models/product_image_input.dart';
import 'package:inventory_mobile/domain/models/product_list_query.dart';
import 'package:inventory_mobile/domain/models/product_mutations.dart';
import 'package:inventory_mobile/domain/repositories/product_repository.dart';
import 'package:inventory_mobile/ui/products/product_catalog_controller.dart';

void main() {
  group('ProductCatalogController', () {
    test('loads the first page and maps supported filters', () async {
      final repository = _FakeProductRepository()
        ..responses.add(_page([_product('1')], hasNextPage: true))
        ..responses.add(_page([_product('2')]))
        ..responses.add(_page([_product('3')]));
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final controller = container.read(productCatalogProvider.notifier);

      await controller.loadInitial();
      await controller.setFilter(ProductCatalogFilter.active);
      await controller.setFilter(ProductCatalogFilter.lowStock);

      expect(container.read(productCatalogProvider).products.single.id, '3');
      expect(repository.queries[0].page, 1);
      expect(repository.queries[0].pageSize, 20);
      expect(repository.queries[1].isActive, isTrue);
      expect(repository.queries[2].lowStockOnly, isTrue);
    });

    test('appends load-more results without duplicate products', () async {
      final repository = _FakeProductRepository()
        ..responses.add(_page([_product('1')], hasNextPage: true))
        ..responses.add(_page([_product('1'), _product('2')], page: 2));
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final controller = container.read(productCatalogProvider.notifier);

      await controller.loadInitial();
      await controller.loadMore();

      final state = container.read(productCatalogProvider);
      expect(state.products.map((product) => product.id), ['1', '2']);
      expect(repository.queries.last.page, 2);
      expect(state.hasNextPage, isFalse);
    });

    test('ignores a stale first-page response', () async {
      final first = Completer<AppResult<PaginatedProducts>>();
      final second = Completer<AppResult<PaginatedProducts>>();
      final repository = _FakeProductRepository()
        ..completers.addAll([first, second]);
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final controller = container.read(productCatalogProvider.notifier);

      final firstLoad = controller.reload();
      final secondLoad = controller.setFilter(ProductCatalogFilter.active);
      second.complete(AppSuccess(_page([_product('new')])));
      await secondLoad;
      first.complete(AppSuccess(_page([_product('stale')])));
      await firstLoad;

      expect(container.read(productCatalogProvider).products.single.id, 'new');
    });

    test('maps thrown repository errors to a stable error state', () async {
      final repository = _FakeProductRepository()
        ..thrownError = StateError('socket closed');
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final controller = container.read(productCatalogProvider.notifier);

      await controller.loadInitial();

      final state = container.read(productCatalogProvider);
      expect(state.isLoading, isFalse);
      expect(state.error?.code, AppErrorCode.unexpected);
      expect(state.error?.message, 'Unexpected error loading products.');
    });

    test('preserves thrown AppException details as a failure state', () async {
      final repository = _FakeProductRepository()
        ..thrownError = const AppException(
          code: AppErrorCode.networkError,
          message: 'Could not complete the backend request.',
        );
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final controller = container.read(productCatalogProvider.notifier);

      await controller.loadInitial();

      final state = container.read(productCatalogProvider);
      expect(state.isLoading, isFalse);
      expect(state.error?.code, AppErrorCode.networkError);
      expect(state.error?.message, 'Could not complete the backend request.');
    });
  });
}

final class _FakeProductRepository implements ProductRepository {
  final responses = <PaginatedProducts>[];
  final completers = <Completer<AppResult<PaginatedProducts>>>[];
  final queries = <ProductListQuery>[];
  Object? thrownError;

  @override
  Future<AppResult<PaginatedProducts>> listProducts(ProductListQuery query) {
    queries.add(query);
    final error = thrownError;
    if (error != null) throw error;
    if (completers.isNotEmpty) return completers.removeAt(0).future;
    return Future.value(AppSuccess(responses.removeAt(0)));
  }

  @override
  Future<AppResult<Product>> createProduct(CreateProductInput input) =>
      throw UnimplementedError();

  @override
  Future<AppResult<void>> deactivateProduct(String productId) =>
      throw UnimplementedError();

  @override
  Future<AppResult<void>> activateProduct(String productId) =>
      throw UnimplementedError();

  @override
  Future<AppResult<Product>> getProduct(String productId) =>
      throw UnimplementedError();

  @override
  Future<AppResult<Product>> updateProduct(
    String productId,
    UpdateProductInput input,
  ) => throw UnimplementedError();

  @override
  Future<AppResult<Product>> uploadProductImage(
    String productId,
    ProductImageInput image,
  ) => throw UnimplementedError();
}

PaginatedProducts _page(
  List<Product> products, {
  int page = 1,
  bool hasNextPage = false,
}) {
  return PaginatedProducts(
    items: products,
    total: products.length,
    page: page,
    pageSize: 20,
    hasNextPage: hasNextPage,
  );
}

Product _product(String id) {
  return Product(
    id: id,
    name: 'Producto $id',
    sku: 'SKU-$id',
    category: 'General',
    minStock: 5,
    isActive: id != '2',
    createdAt: DateTime(2026),
  );
}
