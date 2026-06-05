import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/stock_overview_rest_dto.dart';

/// REST data source for read-only stock balances.
class RestApiStockDataSource {
  const RestApiStockDataSource(this._dio);

  final Dio _dio;

  Future<List<StockOverviewRestDto>> fetchStockByBranch(String branchId) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        '/stock',
        queryParameters: <String, dynamic>{'branchId': branchId},
      );
    } on DioException catch (e, stack) {
      throw _mapDioException(e, stack);
    } catch (e, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected error loading stock.',
        cause: e,
        stackTrace: stack,
      );
    }

    final items = _extractItems(response.data);
    return items
        .map((item) => StockOverviewRestDto.fromJson(item))
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _extractItems(Object? data) {
    final rawItems = switch (data) {
      List list => list,
      Map map when map['items'] is List => map['items'] as List,
      _ => throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Invalid stock response: payload is not a list.',
        details: {'received': data},
      ),
    };

    return rawItems
        .map((item) {
          if (item is! Map) {
            throw AppException(
              code: AppErrorCode.unexpected,
              message: 'Invalid stock response: item is not a JSON object.',
              details: {'received': item},
            );
          }
          return Map<String, dynamic>.from(item);
        })
        .toList(growable: false);
  }

  AppException _mapDioException(DioException e, StackTrace stack) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          code: AppErrorCode.timeout,
          message: 'Stock request timed out.',
          cause: e,
          stackTrace: stack,
        );
      case DioExceptionType.badResponse:
        return AppException(
          code: _statusToErrorCode(e.response?.statusCode),
          message:
              'Backend returned unexpected status ${e.response?.statusCode}.',
          cause: e,
          stackTrace: stack,
        );
      case DioExceptionType.connectionError:
        return AppException(
          code: AppErrorCode.networkError,
          message: 'Cannot reach the backend.',
          cause: e,
          stackTrace: stack,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppException(
          code: AppErrorCode.networkError,
          message: 'Stock request failed: ${e.message ?? 'unknown'}.',
          cause: e,
          stackTrace: stack,
        );
    }
  }

  AppErrorCode _statusToErrorCode(int? statusCode) {
    return switch (statusCode) {
      400 => AppErrorCode.validationError,
      401 => AppErrorCode.unauthorized,
      403 => AppErrorCode.forbidden,
      404 => AppErrorCode.notFound,
      503 => AppErrorCode.serviceUnavailable,
      _ => AppErrorCode.networkError,
    };
  }
}
