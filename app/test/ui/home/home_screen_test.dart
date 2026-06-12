import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/product_providers.dart';
import 'package:inventory_mobile/domain/models/paginated_products.dart';
import 'package:inventory_mobile/domain/models/product.dart';
import 'package:inventory_mobile/domain/models/product_image_input.dart';
import 'package:inventory_mobile/domain/models/product_list_query.dart';
import 'package:inventory_mobile/domain/models/product_mutations.dart';
import 'package:inventory_mobile/domain/repositories/product_repository.dart';
import 'package:inventory_mobile/ui/home/home_screen.dart';
import 'package:inventory_mobile/ui/products/product_form_screen.dart';

void main() {
  testWidgets('loads active and low-stock totals for the home KPIs', (
    tester,
  ) async {
    final repository = _FakeProductRepository();
    await _pumpHome(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('17'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('-'), findsNWidgets(2));
    expect(repository.queries, hasLength(2));

    final activeQuery = repository.queries.firstWhere(
      (query) => query.isActive == true,
    );
    expect(activeQuery.page, 1);
    expect(activeQuery.pageSize, 1);

    final lowStockQuery = repository.queries.firstWhere(
      (query) => query.lowStockOnly == true,
    );
    expect(lowStockQuery.page, 1);
    expect(lowStockQuery.pageSize, 1);
  });

  testWidgets('opens the existing product creation form from quick actions', (
    tester,
  ) async {
    final repository = _FakeProductRepository();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/products/new',
          builder: (_, _) => const ProductFormScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [productRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Nuevo producto'));
    await tester.tap(find.text('Nuevo producto'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product-name-field')), findsOneWidget);
  });
}

Future<void> _pumpHome(WidgetTester tester, ProductRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
}

final class _FakeProductRepository implements ProductRepository {
  final queries = <ProductListQuery>[];

  @override
  Future<AppResult<PaginatedProducts>> listProducts(
    ProductListQuery query,
  ) async {
    queries.add(query);
    return AppSuccess(
      PaginatedProducts(
        items: const [],
        total: query.isActive == true ? 17 : 4,
        page: 1,
        pageSize: 1,
        hasNextPage: false,
      ),
    );
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
