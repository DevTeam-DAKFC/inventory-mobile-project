import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:inventory_mobile/ui/products/products_screen.dart';

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
  _FakeProductRepository(this.onList);

  final Future<AppResult<PaginatedProducts>> Function(ProductListQuery query)
  onList;
  final queries = <ProductListQuery>[];

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
