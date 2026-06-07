import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/domain/models/paginated_products.dart';
import 'package:inventory_mobile/domain/models/product.dart';
import 'package:inventory_mobile/domain/models/product_image_input.dart';
import 'package:inventory_mobile/domain/models/product_list_query.dart';
import 'package:inventory_mobile/domain/models/product_mutations.dart';
import 'package:inventory_mobile/domain/repositories/product_repository.dart';
import 'package:inventory_mobile/domain/services/product_image_picker.dart';
import 'package:inventory_mobile/ui/products/product_form_controller.dart';

void main() {
  group('ProductFormController', () {
    test('initializes in create mode', () {
      final controller = _controller();
      addTearDown(controller.dispose);

      expect(controller.state.mode, ProductFormMode.create);
      expect(controller.state.name, isEmpty);
      expect(controller.state.isLoading, isFalse);
    });

    test('initializes edit mode from an existing product', () {
      final controller = _controller(product: _product());
      addTearDown(controller.dispose);

      expect(controller.state.mode, ProductFormMode.edit);
      expect(controller.state.name, 'Arroz');
      expect(controller.state.minStock, '10');
    });

    test('loads an existing product when only productId is provided', () async {
      final repository = _FakeProductRepository()
        ..getResult = AppSuccess(_product());
      final controller = _controller(repository: repository, productId: 'p1');
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(repository.requestedProductId, 'p1');
      expect(controller.state.originalProduct?.id, 'p1');
    });

    test('validates required fields and minimum stock', () async {
      final controller = _controller();
      addTearDown(controller.dispose);

      await controller.save();

      expect(
        controller.state.fieldErrors.keys,
        containsAll(['name', 'sku', 'category', 'minStock']),
      );
      controller
        ..setName('A')
        ..setSku('S')
        ..setCategory('C')
        ..setMinStock('-1');
      await controller.save();
      expect(controller.state.fieldErrors['minStock'], contains('negativo'));
    });

    test('clears a field error when the field is corrected', () async {
      final controller = _controller();
      addTearDown(controller.dispose);
      await controller.save();

      controller.setName('Arroz');

      expect(controller.state.fieldErrors, isNot(contains('name')));
      expect(controller.state.fieldErrors, contains('sku'));
    });

    test('creates a product successfully', () async {
      final repository = _FakeProductRepository()
        ..createResult = AppSuccess(_product());
      final controller = _validCreateController(repository);
      addTearDown(controller.dispose);

      final outcome = await controller.save();

      expect(outcome, ProductFormSaveOutcome.success);
      expect(repository.createdInput?.name, 'Arroz');
      expect(repository.createdInput?.minStock, 10);
    });

    test('edits with a partial PATCH and omits unchanged fields', () async {
      final repository = _FakeProductRepository()
        ..updateResult = AppSuccess(_product(name: 'Arroz premium'));
      final controller = _controller(
        repository: repository,
        product: _product(),
      );
      addTearDown(controller.dispose);
      controller.setName('Arroz premium');

      await controller.save();

      final input = repository.updatedInput!;
      expect(input.name.isPresent, isTrue);
      expect(input.name.value, 'Arroz premium');
      expect(input.sku.isPresent, isFalse);
      expect(input.barcode.isPresent, isFalse);
      expect(input.minStock.isPresent, isFalse);
    });

    test('does not PATCH when no edit field changed', () async {
      final repository = _FakeProductRepository();
      final controller = _controller(
        repository: repository,
        product: _product(),
      );
      addTearDown(controller.dispose);

      final outcome = await controller.save();

      expect(outcome, ProductFormSaveOutcome.success);
      expect(repository.updatedInput, isNull);
    });

    test('clears optional values and existing image through PATCH', () async {
      final repository = _FakeProductRepository()
        ..updateResult = AppSuccess(_product());
      final controller = _controller(
        repository: repository,
        product: _product(imageUrl: '/images/old.jpg'),
      );
      addTearDown(controller.dispose);
      controller
        ..setBarcode('')
        ..setDescription('')
        ..removeImage();

      await controller.save();

      final input = repository.updatedInput!;
      expect(input.barcode.isPresent, isTrue);
      expect(input.barcode.value, isNull);
      expect(input.description.isPresent, isTrue);
      expect(input.description.value, isNull);
      expect(input.imageUrl.isPresent, isTrue);
      expect(input.imageUrl.value, isNull);
    });

    for (final field in ['sku', 'barcode']) {
      test('maps a $field conflict to its field', () async {
        final repository = _FakeProductRepository()
          ..createResult = AppFailure(
            AppException(
              code: AppErrorCode.conflict,
              message: 'Duplicate product.',
              details: {
                'fieldErrors': [
                  {'field': field, 'message': '$field duplicado'},
                ],
              },
            ),
          );
        final controller = _validCreateController(repository);
        addTearDown(controller.dispose);

        await controller.save();

        expect(controller.state.fieldErrors[field], '$field duplicado');
        expect(controller.state.generalError, isNull);
      });
    }

    test('keeps entered values after a general backend error', () async {
      final repository = _FakeProductRepository()
        ..createResult = const AppFailure(
          AppException(code: AppErrorCode.networkError, message: 'network'),
        );
      final controller = _validCreateController(repository);
      addTearDown(controller.dispose);

      await controller.save();

      expect(controller.state.name, 'Arroz');
      expect(controller.state.generalError, contains('servidor'));
    });

    test('handles successful, cancelled and failed image selection', () async {
      final picker = _FakeProductImagePicker()
        ..results.addAll([
          AppSuccess(_image()),
          const AppSuccess<ProductImageInput?>(null),
          const AppFailure(
            AppException(
              code: AppErrorCode.validationError,
              message: 'Imagen inválida',
            ),
          ),
        ]);
      final controller = _controller(picker: picker);
      addTearDown(controller.dispose);

      await controller.selectImage();
      expect(controller.state.selectedImage, isNotNull);
      controller.removeImage();
      await controller.selectImage();
      expect(controller.state.selectedImage, isNull);
      await controller.selectImage();
      expect(controller.state.generalError, 'Imagen inválida');
    });

    test('saves and uploads a selected image', () async {
      final repository = _FakeProductRepository()
        ..createResult = AppSuccess(_product())
        ..uploadResult = AppSuccess(_product(imageUrl: '/images/p1.jpg'));
      final picker = _FakeProductImagePicker()
        ..results.add(AppSuccess(_image()));
      final controller = _validCreateController(repository, picker: picker);
      addTearDown(controller.dispose);
      await controller.selectImage();

      final outcome = await controller.save();

      expect(outcome, ProductFormSaveOutcome.success);
      expect(repository.uploadedProductId, 'p1');
      expect(controller.state.savedProduct?.imageUrl, '/images/p1.jpg');
    });

    test(
      'reports partial failure when image upload fails after save',
      () async {
        final repository = _FakeProductRepository()
          ..createResult = AppSuccess(_product())
          ..uploadResult = const AppFailure(
            AppException(code: AppErrorCode.timeout, message: 'timeout'),
          );
        final picker = _FakeProductImagePicker()
          ..results.add(AppSuccess(_image()));
        final controller = _validCreateController(repository, picker: picker);
        addTearDown(controller.dispose);
        await controller.selectImage();

        final outcome = await controller.save();

        expect(outcome, ProductFormSaveOutcome.imageUploadFailed);
        expect(controller.state.savedProduct?.id, 'p1');
        expect(controller.state.imageUploadFailed, isTrue);
        expect(controller.state.generalError, contains('producto se guardó'));
      },
    );

    test('retries only image upload after a partial failure', () async {
      final repository = _FakeProductRepository()
        ..createResult = AppSuccess(_product())
        ..uploadResult = const AppFailure(
          AppException(code: AppErrorCode.timeout, message: 'timeout'),
        );
      final picker = _FakeProductImagePicker()
        ..results.add(AppSuccess(_image()));
      final controller = _validCreateController(repository, picker: picker);
      addTearDown(controller.dispose);
      await controller.selectImage();
      await controller.save();
      repository.uploadResult = AppSuccess(
        _product(imageUrl: '/images/p1.jpg'),
      );

      final outcome = await controller.save();

      expect(outcome, ProductFormSaveOutcome.success);
      expect(repository.createCalls, 1);
      expect(repository.uploadCalls, 2);
    });
  });
}

ProductFormController _controller({
  _FakeProductRepository? repository,
  _FakeProductImagePicker? picker,
  String? productId,
  Product? product,
}) => ProductFormController(
  repository ?? _FakeProductRepository(),
  picker ?? _FakeProductImagePicker(),
  productId: productId,
  product: product,
);

ProductFormController _validCreateController(
  _FakeProductRepository repository, {
  _FakeProductImagePicker? picker,
}) {
  final controller = _controller(repository: repository, picker: picker);
  controller
    ..setName('Arroz')
    ..setSku('ARR-001')
    ..setCategory('Abarrotes')
    ..setMinStock('10');
  return controller;
}

final class _FakeProductRepository implements ProductRepository {
  AppResult<Product> getResult = AppSuccess(_product());
  AppResult<Product> createResult = AppSuccess(_product());
  AppResult<Product> updateResult = AppSuccess(_product());
  AppResult<Product> uploadResult = AppSuccess(_product());
  String? requestedProductId;
  CreateProductInput? createdInput;
  UpdateProductInput? updatedInput;
  String? uploadedProductId;
  int createCalls = 0;
  int uploadCalls = 0;

  @override
  Future<AppResult<Product>> getProduct(String productId) async {
    requestedProductId = productId;
    return getResult;
  }

  @override
  Future<AppResult<Product>> createProduct(CreateProductInput input) async {
    createCalls++;
    createdInput = input;
    return createResult;
  }

  @override
  Future<AppResult<Product>> updateProduct(
    String productId,
    UpdateProductInput input,
  ) async {
    updatedInput = input;
    return updateResult;
  }

  @override
  Future<AppResult<Product>> uploadProductImage(
    String productId,
    ProductImageInput image,
  ) async {
    uploadCalls++;
    uploadedProductId = productId;
    return uploadResult;
  }

  @override
  Future<AppResult<void>> deactivateProduct(String productId) =>
      throw UnimplementedError();

  @override
  Future<AppResult<PaginatedProducts>> listProducts(ProductListQuery query) =>
      throw UnimplementedError();
}

final class _FakeProductImagePicker implements ProductImagePicker {
  final results = <AppResult<ProductImageInput?>>[];

  @override
  Future<AppResult<ProductImageInput?>> pickFromGallery() async =>
      results.removeAt(0);
}

Product _product({String name = 'Arroz', String? imageUrl}) => Product(
  id: 'p1',
  name: name,
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
