import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_notification_token_data_source.dart';
import 'package:inventory_mobile/data/dto/notification_token_create_request_dto.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late RestApiNotificationTokenDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiNotificationTokenDataSource(dio);
  });

  test('POST uses /notification-tokens and parses response', () async {
    const request = NotificationTokenCreateRequestDto(
      token: 'fcm-token',
      platform: 'android',
    );
    when(
      () => dio.post<dynamic>('/notification-tokens', data: request.toJson()),
    ).thenAnswer(
      (_) async =>
          _response('/notification-tokens', _tokenJson(), statusCode: 201),
    );

    final dto = await sut.createNotificationToken(request);

    expect(dto.id, 'token-id');
    expect(dto.updatedAt, isNull);
    verify(
      () => dio.post<dynamic>('/notification-tokens', data: request.toJson()),
    ).called(1);
  });

  test('DELETE uses /notification-tokens/{tokenId} and accepts 204', () async {
    when(() => dio.delete<dynamic>('/notification-tokens/token-id')).thenAnswer(
      (_) async =>
          _response('/notification-tokens/token-id', null, statusCode: 204),
    );

    await sut.deleteNotificationToken('token-id');

    verify(
      () => dio.delete<dynamic>('/notification-tokens/token-id'),
    ).called(1);
  });

  test('maps Dio errors with the shared REST error mapper', () async {
    const request = NotificationTokenCreateRequestDto(
      token: 'fcm-token',
      platform: 'android',
    );
    when(
      () => dio.post<dynamic>('/notification-tokens', data: request.toJson()),
    ).thenThrow(_badResponse('/notification-tokens', 401));

    await expectLater(
      sut.createNotificationToken(request),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          AppErrorCode.unauthorized,
        ),
      ),
    );
  });
}

Response<dynamic> _response(
  String path,
  dynamic data, {
  required int statusCode,
}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );
}

DioException _badResponse(String path, int statusCode) {
  final requestOptions = RequestOptions(path: path);
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
    ),
  );
}

Map<String, dynamic> _tokenJson() => {
  'id': 'token-id',
  'token': 'fcm-token',
  'platform': 'android',
  'createdAt': '2026-06-10T00:00:00Z',
  'updatedAt': null,
};
