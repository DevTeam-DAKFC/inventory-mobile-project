import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/notification_token_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/notification_token_mapper.dart';
import 'package:inventory_mobile/domain/models/notification_token.dart';

void main() {
  group('NotificationTokenMapper', () {
    test('maps REST DTO to domain without inventing a user id', () {
      final dto = NotificationTokenRestDto(
        id: 'token-id',
        token: 'fcm-token',
        platform: 'android',
        createdAt: DateTime.utc(2026, 6, 10),
      );

      final token = NotificationTokenMapper.toDomain(dto);

      expect(token.id, 'token-id');
      expect(token.token, 'fcm-token');
      expect(token.platform, PlatformType.android);
      expect(token.createdAt, DateTime.utc(2026, 6, 10));
      expect(token.userId, isNull);
    });

    test('maps supported platforms to wire values', () {
      expect(
        NotificationTokenMapper.platformToWire(PlatformType.android),
        'android',
      );
      expect(NotificationTokenMapper.platformToWire(PlatformType.ios), 'ios');
      expect(NotificationTokenMapper.platformToWire(PlatformType.web), 'web');
    });

    test('maps unknown wire platform to unknown', () {
      expect(
        NotificationTokenMapper.platformFromWire('other'),
        PlatformType.unknown,
      );
    });
  });
}
