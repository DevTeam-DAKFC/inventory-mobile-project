import '../../domain/models/notification_token.dart';
import '../dto/notification_token_rest_dto.dart';

final class NotificationTokenMapper {
  const NotificationTokenMapper._();

  static NotificationToken toDomain(NotificationTokenRestDto dto) {
    return NotificationToken(
      id: dto.id,
      token: dto.token,
      platform: platformFromWire(dto.platform),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static PlatformType platformFromWire(String platform) {
    return switch (platform) {
      'android' => PlatformType.android,
      'ios' => PlatformType.ios,
      'web' => PlatformType.web,
      _ => PlatformType.unknown,
    };
  }

  static String platformToWire(PlatformType platform) {
    return switch (platform) {
      PlatformType.android => 'android',
      PlatformType.ios => 'ios',
      PlatformType.web => 'web',
      PlatformType.unknown => 'unknown',
    };
  }
}
