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
import 'package:inventory_mobile/ui/products/product_detail_screen.dart';
import 'package:inventory_mobile/ui/products/product_form_screen.dart';

void main() {
  testWidgets('shows loading and renders real product data', (tester) async {
    final completer = Completer<AppResult<Product>>();
    final repository = _FakeProductRepository((_) => completer.future);
    await _pumpDetail(tester, repository);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(AppSuccess(_product(active: true)));
    await tester.pumpAndSettle();

    expect(find.text('Producto real'), findsOneWidget);
    expect(find.text('SKU-REAL'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('744100100001'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Descripción real'), findsOneWidget);
    expect(find.text('ACTIVO'), findsOneWidget);
    expect(find.text('Desactivar producto'), findsOneWidget);
    expect(
      find.text('Stock por sucursal pendiente de integración'),
      findsOneWidget,
    );
    expect(find.text('Movimientos pendientes de integración'), findsOneWidget);
    expect(find.textContaining('unid.'), findsNothing);
    expect(find.text('Registrar entrada'), findsNothing);
    expect(find.text('Registrar salida'), findsNothing);
  });

  testWidgets('renders placeholder and safe values for null optional fields', (
    tester,
  ) async {
    final repository = _FakeProductRepository(
      (_) async => AppSuccess(_product(active: false, optionalFields: false)),
    );
    await _pumpDetail(tester, repository);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('product-detail-image-placeholder')),
      findsOneWidget,
    );
    expect(find.text('No disponible'), findsOneWidget);
    expect(find.text('Sin descripción'), findsOneWidget);
    expect(find.text('INACTIVO'), findsOneWidget);
    expect(find.text('Desactivar producto'), findsNothing);
  });

  testWidgets('shows repository error and retry action', (tester) async {
    final repository = _FakeProductRepository(
      (_) async => const AppFailure(
        AppException(code: AppErrorCode.networkError, message: 'Sin conexión'),
      ),
    );
    await _pumpDetail(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar el producto'), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('opens and closes image preview from detail', (tester) async {
    final repository = _FakeProductRepository(
      (_) async => AppSuccess(_product(active: true)),
    );
    await _pumpDetail(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-detail-image-tap')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('product-image-preview-dialog')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('close-product-image-preview')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-image-preview-dialog')), findsNothing);
  });

  testWidgets('edit button opens the existing edit form', (tester) async {
    final product = _product(active: true);
    final repository = _FakeProductRepository((_) async => AppSuccess(product));
    final router = GoRouter(
      initialLocation: '/products/1',
      routes: [
        GoRoute(
          path: '/products/:id',
          builder: (_, state) =>
              ProductDetailScreen(productId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
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

    await tester.tap(find.byKey(const Key('edit-product-button')));
    await tester.pumpAndSettle();

    expect(find.text('Editar producto'), findsOneWidget);
  });

  testWidgets('canceling deactivation does not call the repository', (
    tester,
  ) async {
    final repository = _FakeProductRepository(
      (_) async => AppSuccess(_product(active: true)),
    );
    await _pumpDetail(tester, repository);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('deactivate-product-button')),
    );
    await tester.tap(find.byKey(const Key('deactivate-product-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('deactivate-product-dialog')), findsOneWidget);
    expect(find.textContaining('no será eliminado'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel-deactivate-product')));
    await tester.pumpAndSettle();
    expect(repository.deactivateCalls, 0);
  });

  testWidgets(
    'successful deactivation updates detail and prevents double send',
    (tester) async {
      final completer = Completer<AppResult<void>>();
      final repository = _FakeProductRepository(
        (_) async => AppSuccess(_product(active: true)),
        onDeactivate: (_) => completer.future,
      );
      await _pumpDetail(tester, repository);
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('deactivate-product-button')),
      );
      await tester.tap(find.byKey(const Key('deactivate-product-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-deactivate-product')));
      await tester.pump();

      expect(repository.deactivatedProductId, '1');
      expect(repository.deactivateCalls, 1);
      final confirm = tester.widget<FilledButton>(
        find.byKey(const Key('confirm-deactivate-product')),
      );
      expect(confirm.onPressed, isNull);

      await tester.tap(
        find.byKey(const Key('confirm-deactivate-product')),
        warnIfMissed: false,
      );
      expect(repository.deactivateCalls, 1);

      completer.complete(const AppSuccess(null));
      await tester.pumpAndSettle();

      expect(find.text('INACTIVO'), findsOneWidget);
      expect(find.text('Desactivar producto'), findsNothing);
    },
  );

  testWidgets('deactivation error keeps product active and allows retry', (
    tester,
  ) async {
    final repository = _FakeProductRepository(
      (_) async => AppSuccess(_product(active: true)),
      onDeactivate: (_) async => const AppFailure(
        AppException(code: AppErrorCode.networkError, message: 'Sin conexión'),
      ),
    );
    await _pumpDetail(tester, repository);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('deactivate-product-button')),
    );
    await tester.tap(find.byKey(const Key('deactivate-product-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-deactivate-product')));
    await tester.pumpAndSettle();

    expect(find.text('ACTIVO'), findsOneWidget);
    expect(find.text('No se pudo desactivar: Sin conexión'), findsOneWidget);
    final confirm = tester.widget<FilledButton>(
      find.byKey(const Key('confirm-deactivate-product')),
    );
    expect(confirm.onPressed, isNotNull);
  });
}

Future<void> _pumpDetail(WidgetTester tester, ProductRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: ProductDetailScreen(productId: '1')),
    ),
  );
}

final class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.onGet, {this.onDeactivate});

  final Future<AppResult<Product>> Function(String productId) onGet;
  final Future<AppResult<void>> Function(String productId)? onDeactivate;
  int deactivateCalls = 0;
  String? deactivatedProductId;

  @override
  Future<AppResult<Product>> getProduct(String productId) => onGet(productId);

  @override
  Future<AppResult<PaginatedProducts>> listProducts(ProductListQuery query) =>
      throw UnimplementedError();

  @override
  Future<AppResult<Product>> createProduct(CreateProductInput input) =>
      throw UnimplementedError();

  @override
  Future<AppResult<void>> deactivateProduct(String productId) {
    deactivateCalls++;
    deactivatedProductId = productId;
    return onDeactivate?.call(productId) ??
        Future.value(const AppSuccess(null));
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

Product _product({required bool active, bool optionalFields = true}) {
  return Product(
    id: '1',
    name: 'Producto real',
    sku: 'SKU-REAL',
    barcode: optionalFields ? '744100100001' : null,
    category: 'General',
    description: optionalFields ? 'Descripción real' : null,
    imageUrl: optionalFields ? 'https://example.com/product.jpg' : null,
    minStock: 5,
    isActive: active,
    createdAt: DateTime(2026),
  );
}
