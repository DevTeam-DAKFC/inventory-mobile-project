import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:inventory_mobile/ui/products/products_screen.dart';
import 'package:inventory_mobile/ui/products/product_form_screen.dart';

void main() {
  testWidgets('renders loading and then product cards with status', (
    tester,
  ) async {
    final completer = Completer<AppResult<PaginatedProducts>>();
    final repository = _FakeProductRepository((_) => completer.future);
    await _pumpScreen(tester, repository);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(
      AppSuccess(
        _page([_product('1', active: true), _product('2', active: false)]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Producto 1'), findsOneWidget);
    expect(find.text('ACTIVO'), findsOneWidget);
    expect(find.text('INACTIVO'), findsOneWidget);
    expect(find.byKey(const Key('branch-selector')), findsOneWidget);
    expect(find.text('Tienda Central'), findsOneWidget);
    expect(find.text('Agotados'), findsOneWidget);
  });

  testWidgets('renders empty and failure states', (tester) async {
    final emptyRepository = _FakeProductRepository(
      (_) async => AppSuccess(_page([])),
    );
    await _pumpScreen(tester, emptyRepository);
    await tester.pumpAndSettle();
    expect(find.text('No se encontraron productos'), findsOneWidget);

    final failureRepository = _FakeProductRepository(
      (_) async => const AppFailure(
        AppException(code: AppErrorCode.networkError, message: 'Sin conexión'),
      ),
    );
    await _pumpScreen(tester, failureRepository);
    await tester.pumpAndSettle();
    expect(find.text('No se pudieron cargar los productos'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('debounces search and applies the active filter', (tester) async {
    final repository = _FakeProductRepository(
      (_) async => AppSuccess(_page([])),
    );
    await _pumpScreen(tester, repository);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('product-search-field')),
      'café',
    );
    await tester.pump(const Duration(milliseconds: 349));
    expect(repository.queries, hasLength(1));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(repository.queries.last.q, 'café');

    await tester.tap(find.text('Activos'));
    await tester.pumpAndSettle();
    expect(repository.queries.last.isActive, isTrue);
  });

  testWidgets('does not apply a fake sold-out filter', (tester) async {
    final repository = _FakeProductRepository(
      (_) async => AppSuccess(_page([])),
    );
    await _pumpScreen(tester, repository);
    await tester.pumpAndSettle();

    expect(repository.queries, hasLength(1));
    await tester.tap(find.text('Agotados'));
    await tester.pumpAndSettle();

    expect(repository.queries, hasLength(1));
  });

  testWidgets('navigates from add button and product card to the form', (
    tester,
  ) async {
    final product = _product('1', active: true);
    final repository = _FakeProductRepository(
      (_) async => AppSuccess(_page([product])),
      onGet: (_) async => AppSuccess(product),
    );
    final router = GoRouter(
      initialLocation: '/products',
      routes: [
        GoRoute(
          path: '/products',
          builder: (_, _) => const ProductsScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const ProductFormScreen()),
            GoRoute(
              path: ':id/edit',
              builder: (_, state) =>
                  ProductFormScreen(productId: state.pathParameters['id']),
            ),
          ],
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

    await tester.tap(find.byKey(const Key('add-product-button')));
    await tester.pumpAndSettle();
    expect(find.text('Nuevo producto'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-card-1')));
    await tester.pumpAndSettle();
    expect(find.text('Editar producto'), findsOneWidget);
    expect(repository.requestedProductId, '1');
  });
}

Future<void> _pumpScreen(WidgetTester tester, ProductRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: ProductsScreen()),
    ),
  );
}

final class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.onList, {this.onGet});

  final Future<AppResult<PaginatedProducts>> Function(ProductListQuery query)
  onList;
  final Future<AppResult<Product>> Function(String productId)? onGet;
  final queries = <ProductListQuery>[];
  String? requestedProductId;

  @override
  Future<AppResult<PaginatedProducts>> listProducts(ProductListQuery query) {
    queries.add(query);
    return onList(query);
  }

  @override
  Future<AppResult<Product>> createProduct(CreateProductInput input) =>
      throw UnimplementedError();

  @override
  Future<AppResult<void>> deactivateProduct(String productId) =>
      throw UnimplementedError();

  @override
  Future<AppResult<Product>> getProduct(String productId) {
    requestedProductId = productId;
    return onGet?.call(productId) ??
        Future.value(AppSuccess(_product(productId, active: true)));
  }

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

PaginatedProducts _page(List<Product> products) {
  return PaginatedProducts(
    items: products,
    total: products.length,
    page: 1,
    pageSize: 20,
    hasNextPage: false,
  );
}

Product _product(String id, {required bool active}) {
  return Product(
    id: id,
    name: 'Producto $id',
    sku: 'SKU-$id',
    category: 'General',
    minStock: 5,
    isActive: active,
    createdAt: DateTime(2026),
  );
}
