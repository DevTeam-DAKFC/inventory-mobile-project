import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/branch_rest_dto.dart';

void main() {
  group('BranchRestDto', () {
    test('parses branch response with numeric id', () {
      final dto = BranchRestDto.fromJson(<String, dynamic>{
        'id': 1,
        'name': 'Sucursal Central',
        'address': 'San Jose centro',
        'isActive': true,
      });

      expect(dto.id, '1');
      expect(dto.name, 'Sucursal Central');
      expect(dto.address, 'San Jose centro');
      expect(dto.isActive, isTrue);
    });

    test('parses branchId when id is not present', () {
      final dto = BranchRestDto.fromJson(<String, dynamic>{
        'branchId': 'branch_north',
        'name': 'Sucursal Norte',
        'address': null,
        'isActive': true,
      });

      expect(dto.id, 'branch_north');
      expect(dto.address, isNull);
    });

    test('throws AppException when required fields are missing', () {
      expect(
        () => BranchRestDto.fromJson(<String, dynamic>{'name': 'Sucursal'}),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.unexpected,
          ),
        ),
      );
    });
  });
}
