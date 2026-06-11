import 'package:dio/dio.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/notification_token_create_request_dto.dart';
import '../../dto/notification_token_rest_dto.dart';
import 'rest_api_error_mapper.dart';

class RestApiNotificationTokenDataSource {
  const RestApiNotificationTokenDataSource(this._dio);

  final Dio _dio;

  Future<NotificationTokenRestDto> createNotificationToken(
    NotificationTokenCreateRequestDto request,
  ) async {
    final response = await _request(
      () => _dio.post<dynamic>('/notification-tokens', data: request.toJson()),
      fallbackMessage: 'No se pudo registrar el token de notificaciones.',
    );
    return NotificationTokenRestDto.fromJson(_jsonObject(response.data));
  }

  Future<void> deleteNotificationToken(String tokenId) async {
    await _request(
      () => _dio.delete<dynamic>('/notification-tokens/$tokenId'),
      fallbackMessage: 'No se pudo eliminar el token de notificaciones.',
    );
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request, {
    required String fallbackMessage,
  }) async {
    try {
      return await request();
    } on DioException catch (error, stack) {
      throw RestApiErrorMapper.mapDioException(
        exception: error,
        stackTrace: stack,
        fallbackMessage: fallbackMessage,
      );
    } on AppException {
      rethrow;
    } catch (error, stack) {
      throw AppException(
        code: AppErrorCode.unexpected,
        message: 'Unexpected notification token backend error.',
        cause: error,
        stackTrace: stack,
      );
    }
  }

  Map<String, dynamic> _jsonObject(dynamic data) {
    if (data is Map && data.keys.every((key) => key is String)) {
      return Map<String, dynamic>.from(data);
    }
    throw AppException(
      code: AppErrorCode.unexpected,
      message: 'Invalid notification token response: payload is not an object.',
      details: {'received': data},
    );
  }
}
