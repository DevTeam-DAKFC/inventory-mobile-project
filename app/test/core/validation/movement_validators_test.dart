import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/validation/movement_validators.dart';

void main() {
  group('MovementValidators field validators', () {
    test('valid productId returns null', () {
      expect(MovementValidators.validateProductId('product_001'), isNull);
    });

    test('empty productId returns error', () {
      expect(MovementValidators.validateProductId(null), isNotNull);
      expect(MovementValidators.validateProductId(''), isNotNull);
      expect(MovementValidators.validateProductId('   '), isNotNull);
    });

    test('valid branchId returns null', () {
      expect(MovementValidators.validateBranchId('branch_001'), isNull);
    });

    test('empty branchId returns error', () {
      expect(MovementValidators.validateBranchId(null), isNotNull);
      expect(MovementValidators.validateBranchId(''), isNotNull);
      expect(MovementValidators.validateBranchId('   '), isNotNull);
    });

    test('valid quantity returns null', () {
      expect(MovementValidators.validateQuantity(1), isNull);
      expect(MovementValidators.validateQuantity(40), isNull);
      expect(MovementValidators.validateQuantity(0.5), isNull);
    });

    test('zero quantity returns error', () {
      expect(MovementValidators.validateQuantity(0), isNotNull);
    });

    test('negative quantity returns error', () {
      expect(MovementValidators.validateQuantity(-1), isNotNull);
      expect(MovementValidators.validateQuantity(-5), isNotNull);
    });

    test('valid reason returns null', () {
      expect(MovementValidators.validateReason('Initial import'), isNull);
      expect(MovementValidators.validateReason('  Sale  '), isNull);
    });

    test('empty reason returns error', () {
      expect(MovementValidators.validateReason(null), isNotNull);
      expect(MovementValidators.validateReason(''), isNotNull);
      expect(MovementValidators.validateReason('   '), isNotNull);
      expect(MovementValidators.validateReason('a'), isNotNull);
    });
  });

  group('MovementValidators.validateOutgoingStock', () {
    test('outgoing stock with enough stock returns null', () {
      expect(
        MovementValidators.validateOutgoingStock(
          availableQuantity: 10,
          requestedQuantity: 5,
        ),
        isNull,
      );
      expect(
        MovementValidators.validateOutgoingStock(
          availableQuantity: 10,
          requestedQuantity: 10,
        ),
        isNull,
      );
    });

    test('outgoing stock with insufficient stock returns error', () {
      expect(
        MovementValidators.validateOutgoingStock(
          availableQuantity: 4,
          requestedQuantity: 10,
        ),
        isNotNull,
      );
      expect(
        MovementValidators.validateOutgoingStock(
          availableQuantity: 0,
          requestedQuantity: 1,
        ),
        isNotNull,
      );
    });

    test('negative available stock returns error', () {
      expect(
        MovementValidators.validateOutgoingStock(
          availableQuantity: -1,
          requestedQuantity: 5,
        ),
        isNotNull,
      );
    });
  });
}
