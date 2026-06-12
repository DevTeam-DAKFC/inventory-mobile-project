import '../../core/result/app_result.dart';
import '../models/notification_token.dart';

abstract class NotificationTokenRepository {
  Future<AppResult<NotificationToken>> createNotificationToken({
    required String token,
    required PlatformType platform,
  });

  Future<AppResult<void>> deleteNotificationToken(String tokenId);
}
