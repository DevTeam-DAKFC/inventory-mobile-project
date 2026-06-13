import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/backend_health.dart';

void main() {
  group('BackendHealth', () {
    test('can be constructed with required fields', () {
      const health = BackendHealth(status: 'ok', service: 'Inventory.Api');

      expect(health.status, 'ok');
      expect(health.service, 'Inventory.Api');
    });

    group('isOk', () {
      test('returns true for lowercase "ok"', () {
        const health = BackendHealth(status: 'ok', service: 'Inventory.Api');
        expect(health.isOk, isTrue);
      });

      test('returns true for uppercase "OK"', () {
        const health = BackendHealth(status: 'OK', service: 'Inventory.Api');
        expect(health.isOk, isTrue);
      });

      test('returns true for mixed-case "Ok"', () {
        const health = BackendHealth(status: 'Ok', service: 'Inventory.Api');
        expect(health.isOk, isTrue);
      });

      test('returns false for "error"', () {
        const health = BackendHealth(status: 'error', service: 'Inventory.Api');
        expect(health.isOk, isFalse);
      });

      test('returns false for "unhealthy"', () {
        const health = BackendHealth(
          status: 'unhealthy',
          service: 'Inventory.Api',
        );
        expect(health.isOk, isFalse);
      });

      test('returns false for empty status', () {
        const health = BackendHealth(status: '', service: 'Inventory.Api');
        expect(health.isOk, isFalse);
      });
    });
  });
}
