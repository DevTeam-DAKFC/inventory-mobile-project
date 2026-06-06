import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/models/product_import_file.dart';
import '../../dto/import_batch_rest_dto.dart';
import '../../dto/paginated_import_batch_error_rest_dto.dart';
import '../../dto/paginated_import_batch_rest_dto.dart';
import 'rest_api_error_mapper.dart';

class RestApiImportBatchDataSource {
  const RestApiImportBatchDataSource(this._dio);

  final Dio _dio;

  Future<ImportBatchRestDto> uploadProductCsv(ProductImportFile file) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '/import-batches/products',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(file.bytes, filename: file.fileName),
        }),
      );
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'Unable to upload product import CSV.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error uploading product import CSV.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _batchDtoFromResponse(response.data);
  }

  Future<PaginatedImportBatchRestDto> getImportBatches({
    int page = 1,
    int pageSize = 20,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '/import-batches',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'Unable to load import batches.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading import batches.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid import batches response: payload is not an object.',
        details: {'received': data},
      );
    }
    return PaginatedImportBatchRestDto.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<ImportBatchRestDto> getImportBatchById(String batchId) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/import-batches/$batchId');
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'Unable to load import batch detail.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading import batch detail.',
        cause: e,
        stackTrace: stack,
      );
    }

    return _batchDtoFromResponse(response.data);
  }

  Future<PaginatedImportBatchErrorRestDto> getImportBatchErrors(
    String batchId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '/import-batches/$batchId/errors',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'Unable to load import batch errors.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading import batch errors.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message:
            'Invalid import batch errors response: payload is not an object.',
        details: {'received': data},
      );
    }
    return PaginatedImportBatchErrorRestDto.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  ImportBatchRestDto _batchDtoFromResponse(dynamic data) {
    if (data is! Map) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid import batch response: payload is not an object.',
        details: {'received': data},
      );
    }
    return ImportBatchRestDto.fromJson(Map<String, dynamic>.from(data));
  }
}
