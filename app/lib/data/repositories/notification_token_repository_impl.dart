import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/notification_token.dart';
import '../../domain/repositories/notification_token_repository.dart';
import '../datasources/rest/rest_api_notification_token_data_source.dart';
import '../dto/notification_token_create_request_dto.dart';
import '../mappers/notification_token_mapper.dart';

final class NotificationTokenRepositoryImpl
    implements NotificationTokenRepository {
  const NotificationTokenRepositoryImpl(this._dataSource);

  final RestApiNotificationTokenDataSource _dataSource;

  @override
  Future<AppResult<NotificationToken>> createNotificationToken({
    required String token,
    required PlatformType platform,
  }) {
    return _guard(
      () async => NotificationTokenMapper.toDomain(
        await _dataSource.createNotificationToken(
          NotificationTokenCreateRequestDto(
            token: token,
            platform: NotificationTokenMapper.platformToWire(platform),
          ),
        ),
      ),
    );
  }

  @override
  Future<AppResult<void>> deleteNotificationToken(String tokenId) {
    return _guard(() => _dataSource.deleteNotificationToken(tokenId));
  }

  Future<AppResult<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return AppSuccess(await operation());
    } on AppException catch (error) {
      return AppFailure(error);
    } catch (error, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Unexpected notification token repository error.',
          cause: error,
          stackTrace: stack,
        ),
      );
    }
  }
}
