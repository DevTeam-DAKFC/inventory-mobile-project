/// Suggested product data returned by an external lookup provider.
///
/// This is not a persisted `Product`. The user must review and confirm the
/// suggested values before creating the corresponding product.
final class ExternalProductSuggestion {
  const ExternalProductSuggestion({
    required this.barcode,
    required this.source,
    this.name,
    this.brand,
    this.category,
    this.imageUrl,
  });

  final String barcode;
  final String? name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final String source;
}
