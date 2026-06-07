import 'package:flutter/foundation.dart';

import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_image_input.dart';
import '../../domain/models/product_mutations.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/product_image_picker.dart';

enum ProductFormMode { create, edit }

enum ProductFormSaveOutcome { failed, success, imageUploadFailed }

final class ProductFormState {
  const ProductFormState({
    required this.mode,
    this.productId,
    this.originalProduct,
    this.name = '',
    this.sku = '',
    this.barcode = '',
    this.category = '',
    this.description = '',
    this.minStock = '',
    this.fieldErrors = const {},
    this.generalError,
    this.selectedImage,
    this.removeExistingImage = false,
    this.isLoading = false,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.savedProduct,
    this.imageUploadFailed = false,
  });

  final ProductFormMode mode;
  final String? productId;
  final Product? originalProduct;
  final String name;
  final String sku;
  final String barcode;
  final String category;
  final String description;
  final String minStock;
  final Map<String, String> fieldErrors;
  final String? generalError;
  final ProductImageInput? selectedImage;
  final bool removeExistingImage;
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingImage;
  final Product? savedProduct;
  final bool imageUploadFailed;

  bool get isEditing => mode == ProductFormMode.edit;

  bool get isBusy => isLoading || isSaving || isUploadingImage;

  String? get existingImageUrl =>
      removeExistingImage ? null : originalProduct?.imageUrl;

  ProductFormState copyWith({
    Product? originalProduct,
    String? name,
    String? sku,
    String? barcode,
    String? category,
    String? description,
    String? minStock,
    Map<String, String>? fieldErrors,
    String? generalError,
    ProductImageInput? selectedImage,
    bool? removeExistingImage,
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingImage,
    Product? savedProduct,
    bool? imageUploadFailed,
    bool clearGeneralError = false,
    bool clearSelectedImage = false,
    bool clearSavedProduct = false,
  }) {
    return ProductFormState(
      mode: mode,
      productId: productId,
      originalProduct: originalProduct ?? this.originalProduct,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      description: description ?? this.description,
      minStock: minStock ?? this.minStock,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      generalError: clearGeneralError
          ? null
          : generalError ?? this.generalError,
      selectedImage: clearSelectedImage
          ? null
          : selectedImage ?? this.selectedImage,
      removeExistingImage: removeExistingImage ?? this.removeExistingImage,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      savedProduct: clearSavedProduct
          ? null
          : savedProduct ?? this.savedProduct,
      imageUploadFailed: imageUploadFailed ?? this.imageUploadFailed,
    );
  }
}

final class ProductFormController extends ChangeNotifier {
  ProductFormController(
    this._repository,
    this._imagePicker, {
    String? productId,
    Product? product,
  }) : _state = ProductFormState(
         mode: productId == null && product == null
             ? ProductFormMode.create
             : ProductFormMode.edit,
         productId: productId ?? product?.id,
       ) {
    if (product != null) _setProduct(product, notify: false);
  }

  final ProductRepository _repository;
  final ProductImagePicker _imagePicker;
  ProductFormState _state;

  ProductFormState get state => _state;

  Future<void> initialize() async {
    if (!_state.isEditing ||
        _state.originalProduct != null ||
        _state.isLoading) {
      return;
    }
    final productId = _state.productId;
    if (productId == null) return;

    _setState(_state.copyWith(isLoading: true, clearGeneralError: true));
    final result = await _repository.getProduct(productId);
    result.when(
      success: (product) {
        _setProduct(product);
      },
      failure: (error) {
        _setState(
          _state.copyWith(
            isLoading: false,
            generalError: _generalMessage(error),
          ),
        );
      },
    );
  }

  void setName(String value) => _setField('name', name: value);

  void setSku(String value) => _setField('sku', sku: value);

  void setBarcode(String value) => _setField('barcode', barcode: value);

  void setCategory(String value) => _setField('category', category: value);

  void setDescription(String value) =>
      _setField('description', description: value);

  void setMinStock(String value) => _setField('minStock', minStock: value);

  Future<void> selectImage() async {
    if (_state.isBusy) return;
    final result = await _imagePicker.pickFromGallery();
    result.when(
      success: (image) {
        if (image == null) return;
        _setState(
          _state.copyWith(
            selectedImage: image,
            removeExistingImage: false,
            clearGeneralError: true,
            imageUploadFailed: false,
          ),
        );
      },
      failure: (error) {
        _setState(_state.copyWith(generalError: _generalMessage(error)));
      },
    );
  }

  void removeImage() {
    _setState(
      _state.copyWith(
        clearSelectedImage: true,
        removeExistingImage: _state.originalProduct?.imageUrl != null,
        clearGeneralError: true,
        imageUploadFailed: false,
      ),
    );
  }

  Future<ProductFormSaveOutcome> save() async {
    if (_state.isBusy) return ProductFormSaveOutcome.failed;
    if (_state.imageUploadFailed &&
        _state.savedProduct != null &&
        _state.selectedImage != null) {
      return _uploadSelectedImage(_state.savedProduct!);
    }
    if (_state.isEditing && _state.originalProduct == null) {
      _setState(
        _state.copyWith(
          generalError: 'No se puede guardar hasta cargar el producto.',
        ),
      );
      return ProductFormSaveOutcome.failed;
    }
    final errors = _validate();
    if (errors.isNotEmpty) {
      _setState(
        _state.copyWith(
          fieldErrors: errors,
          clearGeneralError: true,
          imageUploadFailed: false,
        ),
      );
      return ProductFormSaveOutcome.failed;
    }

    _setState(
      _state.copyWith(
        isSaving: true,
        fieldErrors: const {},
        clearGeneralError: true,
        clearSavedProduct: true,
        imageUploadFailed: false,
      ),
    );

    final result = _state.isEditing
        ? await _updateProduct()
        : await _repository.createProduct(_createInput());
    final saved = result.dataOrNull;
    if (saved == null) {
      _applyBackendError(result.exceptionOrNull!);
      return ProductFormSaveOutcome.failed;
    }

    _setState(_state.copyWith(isSaving: false, savedProduct: saved));
    if (_state.selectedImage == null) return ProductFormSaveOutcome.success;
    return _uploadSelectedImage(saved);
  }

  Future<ProductFormSaveOutcome> _uploadSelectedImage(Product saved) async {
    final image = _state.selectedImage!;
    _setState(_state.copyWith(isUploadingImage: true));
    final upload = await _repository.uploadProductImage(saved.id, image);
    final uploadedProduct = upload.dataOrNull;
    if (uploadedProduct != null) {
      _setState(
        _state.copyWith(
          isUploadingImage: false,
          savedProduct: uploadedProduct,
          clearSelectedImage: true,
          clearGeneralError: true,
          imageUploadFailed: false,
        ),
      );
      return ProductFormSaveOutcome.success;
    }

    _setState(
      _state.copyWith(
        isUploadingImage: false,
        generalError:
            'El producto se guardó, pero no se pudo subir la imagen. '
            '${_generalMessage(upload.exceptionOrNull!)}',
        imageUploadFailed: true,
      ),
    );
    return ProductFormSaveOutcome.imageUploadFailed;
  }

  Future<AppResult<Product>> _updateProduct() {
    final original = _state.originalProduct!;
    final input = _updateInput(original);
    if (!_hasUpdate(input)) {
      return Future.value(AppSuccess(original));
    }
    return _repository.updateProduct(original.id, input);
  }

  CreateProductInput _createInput() => CreateProductInput(
    name: _state.name.trim(),
    sku: _state.sku.trim(),
    barcode: _optional(_state.barcode),
    category: _state.category.trim(),
    description: _optional(_state.description),
    minStock: int.parse(_state.minStock.trim()),
  );

  UpdateProductInput _updateInput(Product original) {
    final name = _state.name.trim();
    final sku = _state.sku.trim();
    final barcode = _optional(_state.barcode);
    final category = _state.category.trim();
    final description = _optional(_state.description);
    final minStock = int.parse(_state.minStock.trim());
    return UpdateProductInput(
      name: name == original.name
          ? const PatchField.absent()
          : PatchField.value(name),
      sku: sku == original.sku
          ? const PatchField.absent()
          : PatchField.value(sku),
      barcode: barcode == original.barcode
          ? const PatchField.absent()
          : PatchField.value(barcode),
      category: category == original.category
          ? const PatchField.absent()
          : PatchField.value(category),
      description: description == original.description
          ? const PatchField.absent()
          : PatchField.value(description),
      imageUrl: _state.removeExistingImage
          ? const PatchField.value(null)
          : const PatchField.absent(),
      minStock: minStock == original.minStock
          ? const PatchField.absent()
          : PatchField.value(minStock),
    );
  }

  bool _hasUpdate(UpdateProductInput input) =>
      input.name.isPresent ||
      input.sku.isPresent ||
      input.barcode.isPresent ||
      input.category.isPresent ||
      input.description.isPresent ||
      input.imageUrl.isPresent ||
      input.minStock.isPresent;

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (_state.name.trim().isEmpty) {
      errors['name'] = 'El nombre es obligatorio.';
    }
    if (_state.sku.trim().isEmpty) {
      errors['sku'] = 'El SKU es obligatorio.';
    }
    if (_state.category.trim().isEmpty) {
      errors['category'] = 'La categoría es obligatoria.';
    }
    final minStock = int.tryParse(_state.minStock.trim());
    if (minStock == null) {
      errors['minStock'] = 'Ingresa un stock mínimo válido.';
    } else if (minStock < 0) {
      errors['minStock'] = 'El stock mínimo no puede ser negativo.';
    }
    return errors;
  }

  void _applyBackendError(AppException error) {
    final fieldErrors = _fieldErrors(error);
    _setState(
      _state.copyWith(
        isSaving: false,
        fieldErrors: fieldErrors,
        generalError: fieldErrors.isEmpty ? _generalMessage(error) : null,
        clearGeneralError: fieldErrors.isNotEmpty,
      ),
    );
  }

  Map<String, String> _fieldErrors(AppException error) {
    final result = <String, String>{};
    final raw = error.details?['fieldErrors'];
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final field = item['field'];
        final message = item['message'];
        if (field is String && message is String) result[field] = message;
      }
    }
    return result;
  }

  String _generalMessage(AppException error) => switch (error.code) {
    AppErrorCode.networkError =>
      'No se pudo conectar con el servidor. Intenta nuevamente.',
    AppErrorCode.timeout => 'La solicitud tardó demasiado. Intenta nuevamente.',
    AppErrorCode.notFound ||
    AppErrorCode.productNotFound => 'El producto ya no existe.',
    _ => error.message,
  };

  void _setProduct(Product product, {bool notify = true}) {
    _state = _state.copyWith(
      originalProduct: product,
      name: product.name,
      sku: product.sku,
      barcode: product.barcode ?? '',
      category: product.category,
      description: product.description ?? '',
      minStock: product.minStock.toString(),
      isLoading: false,
      clearGeneralError: true,
    );
    if (notify) notifyListeners();
  }

  void _setField(
    String field, {
    String? name,
    String? sku,
    String? barcode,
    String? category,
    String? description,
    String? minStock,
  }) {
    final errors = Map<String, String>.from(_state.fieldErrors)..remove(field);
    _setState(
      _state.copyWith(
        name: name,
        sku: sku,
        barcode: barcode,
        category: category,
        description: description,
        minStock: minStock,
        fieldErrors: errors,
        clearGeneralError: true,
      ),
    );
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _setState(ProductFormState value) {
    _state = value;
    notifyListeners();
  }
}
