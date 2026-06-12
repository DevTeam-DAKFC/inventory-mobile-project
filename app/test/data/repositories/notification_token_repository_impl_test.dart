import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_notification_token_data_source.dart';
import 'package:inventory_mobile/data/dto/notification_token_create_request_dto.dart';
import 'package:inventory_mobile/data/dto/notification_token_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/notification_token_repository_impl.dart';
import 'package:inventory_mobile/domain/models/notification_token.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationTokenDataSource extends Mock
    implements RestApiNotificationTokenDataSource {}

void main() {
  late _MockNotificationTokenDataSource dataSource;
  late NotificationTokenRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(
      const NotificationTokenCreateRequestDto(
        token: 'fallback',
        platform: 'android',
      ),
    );
  });

  setUp(() {
    dataSource = _MockNotificationTokenDataSource();
    sut = NotificationTokenRepositoryImpl(dataSource);
  });

  test('create propagates mapped success', () async {
    when(
      () => dataSource.createNotificationToken(any()),
    ).thenAnswer((_) async => _tokenDto());

    final result = await sut.createNotificationToken(
      token: 'fcm-token',
      platform: PlatformType.android,
    );

    expect(result, isA<AppSuccess<NotificationToken>>());
    expect(result.dataOrNull?.id, 'token-id');
    expect(result.dataOrNull?.platform, PlatformType.android);
    final request =
        verify(
              () => dataSource.createNotificationToken(captureAny()),
            ).captured.single
            as NotificationTokenCreateRequestDto;
    expect(request.toJson(), {'token': 'fcm-token', 'platform': 'android'});
  });

  test('delete propagates success', () async {
    when(
      () => dataSource.deleteNotificationToken('token-id'),
    ).thenAnswer((_) async {});

    final result = await sut.deleteNotificationToken('token-id');

    expect(result, isA<AppSuccess<void>>());
  });

  test('preserves mapped REST errors', () async {
    const exception = AppException(
      code: AppErrorCode.unauthorized,
      message: 'Unauthorized.',
    );
    when(
      () => dataSource.deleteNotificationToken('token-id'),
    ).thenThrow(exception);

    final result = await sut.deleteNotificationToken('token-id');

    expect(result, isA<AppFailure<void>>());
    expect(result.exceptionOrNull, same(exception));
  });

  test('maps unexpected errors to AppFailure', () async {
    when(
      () => dataSource.deleteNotificationToken('token-id'),
    ).thenThrow(StateError('boom'));

    final result = await sut.deleteNotificationToken('token-id');

    expect(result, isA<AppFailure<void>>());
    expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
  });
}

NotificationTokenRestDto _tokenDto() {
  return NotificationTokenRestDto(
    id: 'token-id',
    token: 'fcm-token',
    platform: 'android',
    createdAt: DateTime.utc(2026, 6, 10),
  );
}
