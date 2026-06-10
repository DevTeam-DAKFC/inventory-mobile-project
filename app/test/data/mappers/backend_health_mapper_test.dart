import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/data/dto/backend_health_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/backend_health_mapper.dart';

void main() {
  group('BackendHealthMapper', () {
    test('maps DTO to BackendHealth domain model', () {
      const dto = BackendHealthRestDto(status: 'ok', service: 'Inventory.Api');

      final domain = BackendHealthMapper.toDomain(dto);

      expect(domain.status, 'ok');
      expect(domain.service, 'Inventory.Api');
      expect(domain.isOk, isTrue);
    });
  });
}
