import '../../domain/models/external_product_suggestion.dart';
import '../dto/external_product_suggestion_dto.dart';

final class ExternalProductSuggestionMapper {
  const ExternalProductSuggestionMapper._();

  static ExternalProductSuggestion toDomain(ExternalProductSuggestionDto dto) =>
      ExternalProductSuggestion(
        barcode: dto.barcode,
        source: dto.source,
        name: dto.name,
        brand: dto.brand,
        category: dto.category,
        imageUrl: dto.imageUrl,
      );
}
