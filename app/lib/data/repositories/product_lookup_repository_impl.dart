import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/external_product_suggestion.dart';
import '../../domain/repositories/product_lookup_repository.dart';
import '../datasources/rest/rest_api_product_lookup_data_source.dart';
import '../mappers/external_product_suggestion_mapper.dart';

final class ProductLookupRepositoryImpl implements ProductLookupRepository {
  const ProductLookupRepositoryImpl(this._dataSource);

  final RestApiProductLookupDataSource _dataSource;

  @override
  Future<AppResult<ExternalProductSuggestion>> lookupByBarcode(
    String barcode,
  ) async {
    try {
      final dto = await _dataSource.lookupByBarcode(barcode);
      return AppSuccess(ExternalProductSuggestionMapper.toDomain(dto));
    } on AppException catch (error) {
      return AppFailure(error);
    } catch (error, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected product lookup repository error.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }
}
