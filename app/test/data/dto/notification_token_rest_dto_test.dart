import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/notification_token_rest_dto.dart';

void main() {
  group('NotificationTokenRestDto', () {
    test('parses all response fields', () {
      final dto = NotificationTokenRestDto.fromJson({
        'id': 'token-id',
        'token': 'fcm-token',
        'platform': 'android',
        'createdAt': '2026-06-10T00:00:00Z',
        'updatedAt': '2026-06-11T00:00:00Z',
      });

      expect(dto.id, 'token-id');
      expect(dto.token, 'fcm-token');
      expect(dto.platform, 'android');
      expect(dto.createdAt, DateTime.utc(2026, 6, 10));
      expect(dto.updatedAt, DateTime.utc(2026, 6, 11));
    });

    test('accepts null updatedAt', () {
      final dto = NotificationTokenRestDto.fromJson({
        'id': 'token-id',
        'token': 'fcm-token',
        'platform': 'android',
        'createdAt': '2026-06-10T00:00:00Z',
        'updatedAt': null,
      });

      expect(dto.updatedAt, isNull);
    });

    test('throws AppException for invalid required fields', () {
      expect(
        () => NotificationTokenRestDto.fromJson({
          'id': 'token-id',
          'token': 'fcm-token',
          'platform': 'android',
          'createdAt': 'invalid',
        }),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });
  });
}
