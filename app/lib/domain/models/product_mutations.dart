/// Explicit state for a partial-update field.
///
/// An absent [PatchField] is omitted from the request. A present field is
/// serialized even when [value] is `null`.
final class PatchField<T> {
  const PatchField.absent() : isPresent = false, value = null;

  const PatchField.value(T this.value) : isPresent = true;

  final bool isPresent;
  final T? value;
}

/// Values accepted by `POST /products`.
final class CreateProductInput {
  const CreateProductInput({
    required this.name,
    required this.sku,
    required this.category,
    required this.minStock,
    this.barcode,
    this.description,
    this.imageUrl,
    this.isActive,
  });

  final String name;
  final String sku;
  final String category;
  final int minStock;
  final String? barcode;
  final String? description;
  final String? imageUrl;
  final bool? isActive;
}

/// Editable values accepted by `PATCH /products/{productId}`.
final class UpdateProductInput {
  const UpdateProductInput({
    this.name = const PatchField.absent(),
    this.sku = const PatchField.absent(),
    this.barcode = const PatchField.absent(),
    this.category = const PatchField.absent(),
    this.description = const PatchField.absent(),
    this.imageUrl = const PatchField.absent(),
    this.minStock = const PatchField.absent(),
  });

  final PatchField<String> name;
  final PatchField<String> sku;
  final PatchField<String?> barcode;
  final PatchField<String> category;
  final PatchField<String?> description;
  final PatchField<String?> imageUrl;
  final PatchField<int> minStock;
}
