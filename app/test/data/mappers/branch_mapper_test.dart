import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/branch_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/branch_mapper.dart';

void main() {
  group('BranchMapper', () {
    test('maps branch DTO to domain model', () {
      final dto = BranchRestDto(
        id: 'branch-id',
        name: 'Central Branch',
        address: 'Main street',
        isActive: true,
        createdAt: DateTime.utc(2026, 6, 5, 20),
        updatedAt: DateTime.utc(2026, 6, 5, 21),
      );

      final domain = BranchMapper.toDomain(dto);

      expect(domain.id, 'branch-id');
      expect(domain.name, 'Central Branch');
      expect(domain.address, 'Main street');
      expect(domain.isActive, isTrue);
      expect(domain.updatedAt, DateTime.utc(2026, 6, 5, 21));
    });
  });
}
