import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/notification_token_create_request_dto.dart';

void main() {
  test('serializes token and platform', () {
    const dto = NotificationTokenCreateRequestDto(
      token: 'fcm-token',
      platform: 'android',
    );

    expect(dto.toJson(), {'token': 'fcm-token', 'platform': 'android'});
  });
}
