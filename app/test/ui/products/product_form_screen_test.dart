import 'dart:async';
import 'dart:typed_data';

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
import 'package:inventory_mobile/domain/services/product_image_picker.dart';
import 'package:inventory_mobile/ui/products/product_form_screen.dart';

void main() {
  testWidgets('renders the create form and required fields', (tester) async {
    await _pumpForm(tester);

    expect(find.text('Nuevo producto'), findsOneWidget);
    expect(find.text('Imagen del producto'), findsOneWidget);
    expect(find.text('Nombre del producto *'), findsOneWidget);
    expect(find.text('SKU *'), findsOneWidget);
    expect(find.text('Categoría *'), findsOneWidget);
    expect(find.text('Stock mínimo *'), findsOneWidget);
    expect(find.text('Crear producto'), findsOneWidget);
  });

  testWidgets('renders edit values and existing image', (tester) async {
    await _pumpForm(tester, product: _product(imageUrl: '/images/p1.jpg'));
    await tester.pump();

    expect(find.text('Editar producto'), findsOneWidget);
    expect(
      find.byKey(const Key('existing-product-image-preview')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('product-name-field')))
          .controller
          ?.text,
      'Arroz',
    );
    expect(find.text('Guardar cambios'), findsOneWidget);
  });

  testWidgets('shows field errors and clears them after correction', (
    tester,
  ) async {
    await _pumpForm(tester);
    await _tapSave(tester);

    expect(find.text('El nombre es obligatorio.'), findsOneWidget);
    expect(find.text('El SKU es obligatorio.'), findsOneWidget);
    expect(find.text('La categoría es obligatoria.'), findsOneWidget);
    expect(find.text('Ingresa un stock mínimo válido.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('product-name-field')),
      'Arroz',
    );
    await tester.pump();
    expect(find.text('El nombre es obligatorio.'), findsNothing);
  });

  testWidgets('shows loading state while saving', (tester) async {
    final completer = Completer<AppResult<Product>>();
    final repository = _FakeProductRepository()
      ..onCreate = (_) => completer.future;
    await _pumpForm(tester, repository: repository);
    await _fillRequiredFields(tester);

    await _tapSave(tester, settle: false);
    await tester.pump();

    expect(find.text('Guardando...'), findsOneWidget);
    completer.complete(AppSuccess(_product()));
    await tester.pumpAndSettle();
  });

  testWidgets('shows selected image preview', (tester) async {
    final picker = _FakeProductImagePicker(AppSuccess(_image()));
    await _pumpForm(tester, picker: picker);

    await tester.tap(find.byKey(const Key('product-image-picker')));
    await tester.pump();

    expect(
      find.byKey(const Key('selected-product-image-preview')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('remove-product-image-button')),
      findsOneWidget,
    );
  });

  testWidgets('shows image upload state after saving the product', (
    tester,
  ) async {
    final upload = Completer<AppResult<Product>>();
    final repository = _FakeProductRepository()
      ..onUpload = (_, _) => upload.future;
    final picker = _FakeProductImagePicker(AppSuccess(_image()));
    await _pumpForm(tester, repository: repository, picker: picker);
    await tester.tap(find.byKey(const Key('product-image-picker')));
    await tester.pump();
    await _fillRequiredFields(tester);

    await _tapSave(tester, settle: false);
    await tester.pump();
    await tester.pump();

    expect(find.text('Subiendo imagen...'), findsOneWidget);
    upload.complete(AppSuccess(_product(imageUrl: '/images/p1.jpg')));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'shows backend field and general errors without clearing inputs',
    (tester) async {
      final repository = _FakeProductRepository()
        ..createResults.addAll([
          const AppFailure(
            AppException(
              code: AppErrorCode.conflict,
              message: 'Duplicate',
              details: {
                'fieldErrors': [
                  {'field': 'sku', 'message': 'El SKU ya existe.'},
                ],
              },
            ),
          ),
          const AppFailure(
            AppException(code: AppErrorCode.networkError, message: 'network'),
          ),
        ]);
      await _pumpForm(tester, repository: repository);
      await _fillRequiredFields(tester);

      await _tapSave(tester);
      expect(find.text('El SKU ya existe.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('product-sku-field')),
        'ARR-002',
      );
      await _tapSave(tester);
      expect(
        find.byKey(const Key('product-form-general-error')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('product-name-field')))
            .controller
            ?.text,
        'Arroz',
      );
    },
  );

  testWidgets('fills and saves a product', (tester) async {
    final repository = _FakeProductRepository();
    await _pumpForm(tester, repository: repository);
    await _fillRequiredFields(tester);

    await _tapSave(tester);

    expect(repository.createdInput?.sku, 'ARR-001');
    expect(repository.createdInput?.minStock, 10);
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  _FakeProductRepository? repository,
  _FakeProductImagePicker? picker,
  Product? product,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          repository ?? _FakeProductRepository(),
        ),
        productImagePickerProvider.overrideWithValue(
          picker ??
              _FakeProductImagePicker(
                const AppSuccess<ProductImageInput?>(null),
              ),
        ),
      ],
      child: MaterialApp(home: ProductFormScreen(product: product)),
    ),
  );
}

Future<void> _fillRequiredFields(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('product-name-field')), 'Arroz');
  await tester.enterText(find.byKey(const Key('product-sku-field')), 'ARR-001');
  await tester.enterText(
    find.byKey(const Key('product-category-field')),
    'Abarrotes',
  );
  await tester.enterText(
    find.byKey(const Key('product-min-stock-field')),
    '10',
  );
}

Future<void> _tapSave(WidgetTester tester, {bool settle = true}) async {
  final button = find.byKey(const Key('save-product-button'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  if (settle) {
    await tester.pumpAndSettle();
  }
}

final class _FakeProductRepository implements ProductRepository {
  Future<AppResult<Product>> Function(CreateProductInput)? onCreate;
  Future<AppResult<Product>> Function(String, ProductImageInput)? onUpload;
  final createResults = <AppResult<Product>>[];
  CreateProductInput? createdInput;

  @override
  Future<AppResult<Product>> createProduct(CreateProductInput input) {
    createdInput = input;
    if (onCreate != null) {
      return onCreate!(input);
    }
    if (createResults.isNotEmpty) {
      return Future.value(createResults.removeAt(0));
    }
    return Future.value(AppSuccess(_product()));
  }

  @override
  Future<AppResult<Product>> getProduct(String productId) async =>
      AppSuccess(_product());

  @override
  Future<AppResult<Product>> updateProduct(
    String productId,
    UpdateProductInput input,
  ) async => AppSuccess(_product());

  @override
  Future<AppResult<Product>> uploadProductImage(
    String productId,
    ProductImageInput image,
  ) async =>
      onUpload?.call(productId, image) ??
      AppSuccess(_product(imageUrl: '/images/p1.jpg'));

  @override
  Future<AppResult<void>> deactivateProduct(String productId) =>
      throw UnimplementedError();

  @override
  Future<AppResult<PaginatedProducts>> listProducts(ProductListQuery query) =>
      throw UnimplementedError();
}

final class _FakeProductImagePicker implements ProductImagePicker {
  const _FakeProductImagePicker(this.result);

  final AppResult<ProductImageInput?> result;

  @override
  Future<AppResult<ProductImageInput?>> pickFromGallery() async => result;
}

Product _product({String? imageUrl}) => Product(
  id: 'p1',
  name: 'Arroz',
  sku: 'ARR-001',
  barcode: '744100100001',
  category: 'Abarrotes',
  description: 'Descripción',
  imageUrl: imageUrl,
  minStock: 10,
  isActive: true,
  createdAt: DateTime(2026),
);

ProductImageInput _image() => ProductImageInput(
  fileName: 'product.png',
  bytes: Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
  mimeType: 'image/png',
);
