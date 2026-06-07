import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/branch_rest_dto.dart';

void main() {
  group('BranchRestDto', () {
    test('parses branch JSON with optional fields', () {
      final dto = BranchRestDto.fromJson({
        'id': 'branch-id',
        'name': 'Central Branch',
        'address': 'Main street',
        'isActive': true,
        'createdAt': '2026-06-05T20:00:00Z',
        'updatedAt': '2026-06-05T21:00:00Z',
      });

      expect(dto.id, 'branch-id');
      expect(dto.name, 'Central Branch');
      expect(dto.address, 'Main street');
      expect(dto.isActive, isTrue);
      expect(dto.updatedAt, DateTime.parse('2026-06-05T21:00:00Z'));
    });

    test('allows nullable optional fields', () {
      final dto = BranchRestDto.fromJson({
        'id': 'branch-id',
        'name': 'Central Branch',
        'address': null,
        'isActive': true,
        'createdAt': '2026-06-05T20:00:00Z',
        'updatedAt': null,
      });

      expect(dto.address, isNull);
      expect(dto.updatedAt, isNull);
    });

    test('throws AppException for invalid required fields', () {
      expect(
        () => BranchRestDto.fromJson({
          'id': 'branch-id',
          'name': '',
          'isActive': true,
          'createdAt': '2026-06-05T20:00:00Z',
        }),
        throwsA(isA<AppException>()),
      );
    });
  });
}
