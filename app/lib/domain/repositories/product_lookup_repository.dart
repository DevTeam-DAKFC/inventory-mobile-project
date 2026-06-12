import '../../core/result/app_result.dart';
import '../models/external_product_suggestion.dart';

abstract class ProductLookupRepository {
  Future<AppResult<ExternalProductSuggestion>> lookupByBarcode(String barcode);
}
