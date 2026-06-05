import '../../domain/models/product_mutations.dart';

/// JSON request body for `POST /products`.
final class ProductCreateRequest {
  const ProductCreateRequest({
    required this.name,
    required this.sku,
    required this.category,
    required this.minStock,
    this.barcode,
    this.description,
    this.imageUrl,
    this.isActive,
  });

  factory ProductCreateRequest.fromInput(CreateProductInput input) {
    return ProductCreateRequest(
      name: input.name,
      sku: input.sku,
      category: input.category,
      minStock: input.minStock,
      barcode: input.barcode,
      description: input.description,
      imageUrl: input.imageUrl,
      isActive: input.isActive,
    );
  }

  final String name;
  final String sku;
  final String category;
  final int minStock;
  final String? barcode;
  final String? description;
  final String? imageUrl;
  final bool? isActive;

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'category': category,
    'minStock': minStock,
    if (_hasText(barcode)) 'barcode': barcode,
    if (_hasText(description)) 'description': description,
    if (_hasText(imageUrl)) 'imageUrl': imageUrl,
    if (isActive != null) 'isActive': isActive,
  };

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

/// JSON request body for `PATCH /products/{productId}`.
final class ProductUpdateRequest {
  const ProductUpdateRequest(this.input);

  final UpdateProductInput input;

  Map<String, dynamic> toJson() => {
    if (input.name.isPresent) 'name': input.name.value,
    if (input.sku.isPresent) 'sku': input.sku.value,
    if (input.barcode.isPresent) 'barcode': input.barcode.value,
    if (input.category.isPresent) 'category': input.category.value,
    if (input.description.isPresent) 'description': input.description.value,
    if (input.imageUrl.isPresent) 'imageUrl': input.imageUrl.value,
    if (input.minStock.isPresent) 'minStock': input.minStock.value,
  };
}
