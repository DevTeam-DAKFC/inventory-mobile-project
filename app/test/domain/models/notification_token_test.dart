import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/notification_token.dart';

void main() {
  group('PlatformType', () {
    test('exposes android, ios, web and unknown', () {
      expect(PlatformType.values, [
        PlatformType.android,
        PlatformType.ios,
        PlatformType.web,
        PlatformType.unknown,
      ]);
    });
  });

  group('NotificationToken', () {
    test('can be constructed with required fields', () {
      final createdAt = DateTime.utc(2026, 6, 2, 20);
      final token = NotificationToken(
        id: 'token_001',
        userId: 'user_admin_001',
        token: 'fcm_device_token_admin_demo',
        platform: PlatformType.android,
        createdAt: createdAt,
      );

      expect(token.id, 'token_001');
      expect(token.userId, 'user_admin_001');
      expect(token.token, 'fcm_device_token_admin_demo');
      expect(token.platform, PlatformType.android);
      expect(token.createdAt, createdAt);
      expect(token.updatedAt, isNull);
    });

    test('preserves optional updatedAt', () {
      final updatedAt = DateTime.utc(2026, 6, 3);
      final token = NotificationToken(
        id: 't',
        userId: 'u',
        token: 'x',
        platform: PlatformType.ios,
        createdAt: DateTime.utc(2026, 6, 2),
        updatedAt: updatedAt,
      );

      expect(token.updatedAt, updatedAt);
    });
  });
}
