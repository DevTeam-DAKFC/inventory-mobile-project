import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/external_product_suggestion_dto.dart';
import 'rest_error_parser.dart';

class RestApiProductLookupDataSource {
  const RestApiProductLookupDataSource(this._dio);

  final Dio _dio;

  Future<ExternalProductSuggestionDto> lookupByBarcode(String barcode) async {
    try {
      final response = await _dio.get<dynamic>(
        '/product-lookup/${Uri.encodeComponent(barcode)}',
      );
      final data = response.data;
      if (data is! Map || data.keys.any((key) => key is! String)) {
        throw AppException(
          code: AppErrorCode.unexpected,
          message:
              'Invalid product lookup response: payload is not a JSON object.',
          details: {'received': data},
        );
      }
      return ExternalProductSuggestionDto.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (error, stack) {
      throw RestErrorParser.fromDio(error, stack);
    } on AppException {
      rethrow;
    } catch (error, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected product lookup error.',
        cause: error,
        stackTrace: stack,
      );
    }
  }
}
