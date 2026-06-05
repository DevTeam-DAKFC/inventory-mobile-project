/// Device platform reported when registering a notification token.
enum PlatformType { android, ios, web, unknown }

/// Push notification token associated with a user device.
final class NotificationToken {
  const NotificationToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.platform,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String token;
  final PlatformType platform;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
