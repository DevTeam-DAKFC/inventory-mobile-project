import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/auth/access_token_provider.dart';

void main() {
  group('DevAccessTokenProvider', () {
    test('returns the configured token', () async {
      const provider = DevAccessTokenProvider(token: 'token-value');

      await expectLater(provider.getAccessToken(), completion('token-value'));
    });

    test('trims the configured token', () async {
      const provider = DevAccessTokenProvider(token: '  token-value  ');

      await expectLater(provider.getAccessToken(), completion('token-value'));
    });

    test('returns null when the token is empty', () async {
      const provider = DevAccessTokenProvider(token: '   ');

      await expectLater(provider.getAccessToken(), completion(isNull));
    });
  });
}
