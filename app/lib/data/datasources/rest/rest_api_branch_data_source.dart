import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/branch_rest_dto.dart';
import 'rest_api_error_mapper.dart';

class RestApiBranchDataSource {
  const RestApiBranchDataSource(this._dio);

  final Dio _dio;

  Future<List<BranchRestDto>> getBranches() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/branches');
    } on DioException catch (e, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: e,
        stackTrace: stack,
        fallbackMessage: 'Unable to load branches.',
      );
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading branches.',
        cause: e,
        stackTrace: stack,
      );
    }

    final data = response.data;
    if (data is! List) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid branches response: payload is not a list.',
        details: {'received': data},
      );
    }

    return data
        .map(
          (branch) =>
              BranchRestDto.fromJson(Map<String, dynamic>.from(branch as Map)),
        )
        .toList();
  }
}
