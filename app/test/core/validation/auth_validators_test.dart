import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/validation/auth_validators.dart';

void main() {
  group('AuthValidators.validateName', () {
    test('valid name returns null', () {
      expect(AuthValidators.validateName('Ana'), isNull);
      expect(AuthValidators.validateName('  Carlos  '), isNull);
    });

    test('empty name returns error', () {
      expect(AuthValidators.validateName(null), isNotNull);
      expect(AuthValidators.validateName(''), isNotNull);
      expect(AuthValidators.validateName('   '), isNotNull);
    });

    test('short name returns error', () {
      expect(AuthValidators.validateName('A'), isNotNull);
      expect(AuthValidators.validateName(' B '), isNotNull);
    });
  });

  group('AuthValidators.validateEmail', () {
    test('valid email returns null', () {
      expect(AuthValidators.validateEmail('ana@example.com'), isNull);
      expect(AuthValidators.validateEmail(' user.name+tag@sub.example.co '),
          isNull);
    });

    test('invalid email returns error', () {
      expect(AuthValidators.validateEmail('not-an-email'), isNotNull);
      expect(AuthValidators.validateEmail('foo@bar'), isNotNull);
      expect(AuthValidators.validateEmail('@example.com'), isNotNull);
      expect(AuthValidators.validateEmail('user@'), isNotNull);
    });

    test('empty email returns error', () {
      expect(AuthValidators.validateEmail(null), isNotNull);
      expect(AuthValidators.validateEmail(''), isNotNull);
      expect(AuthValidators.validateEmail('   '), isNotNull);
    });
  });

  group('AuthValidators.validatePassword', () {
    test('valid password returns null', () {
      expect(AuthValidators.validatePassword('secret1'), isNull);
      expect(AuthValidators.validatePassword('123456'), isNull);
    });

    test('short password returns error', () {
      expect(AuthValidators.validatePassword('abc'), isNotNull);
      expect(AuthValidators.validatePassword('12345'), isNotNull);
    });

    test('empty password returns error', () {
      expect(AuthValidators.validatePassword(null), isNotNull);
      expect(AuthValidators.validatePassword(''), isNotNull);
    });
  });
}
