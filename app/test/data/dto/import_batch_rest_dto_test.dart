import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/import_batch_rest_dto.dart';

void main() {
  group('ImportBatchRestDto', () {
    test('parses a valid import batch response', () {
      final dto = ImportBatchRestDto.fromJson({
        'id': 'batch-id',
        'fileName': 'products.csv',
        'importedBy': 'user-id',
        'status': 'completed_with_errors',
        'totalRows': 10,
        'processedRows': 10,
        'importedRows': 8,
        'failedRows': 2,
        'createdAt': '2026-06-05T20:00:00Z',
        'completedAt': '2026-06-05T20:01:00Z',
      });

      expect(dto.id, 'batch-id');
      expect(dto.status, 'completed_with_errors');
      expect(dto.failedRows, 2);
      expect(dto.completedAt, DateTime.parse('2026-06-05T20:01:00Z'));
    });

    test('allows null completedAt', () {
      final dto = ImportBatchRestDto.fromJson({
        'id': 'batch-id',
        'fileName': 'products.csv',
        'importedBy': 'user-id',
        'status': 'processing',
        'totalRows': 10,
        'processedRows': 3,
        'importedRows': 2,
        'failedRows': 1,
        'createdAt': '2026-06-05T20:00:00Z',
        'completedAt': null,
      });

      expect(dto.completedAt, isNull);
    });

    test('throws AppException for invalid required fields', () {
      expect(
        () => ImportBatchRestDto.fromJson({
          'id': '',
          'fileName': 'products.csv',
          'importedBy': 'user-id',
          'status': 'completed',
          'totalRows': 10,
          'processedRows': 10,
          'importedRows': 10,
          'failedRows': 0,
          'createdAt': '2026-06-05T20:00:00Z',
        }),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('ImportBatchErrorRestDto', () {
    test('parses a valid import batch error response', () {
      final dto = ImportBatchErrorRestDto.fromJson({
        'id': 'error-id',
        'batchId': 'batch-id',
        'rowNumber': 4,
        'field': 'sku',
        'code': 'duplicate_sku',
        'message': 'SKU already exists.',
        'rawValue': 'RICE-001',
      });

      expect(dto.id, 'error-id');
      expect(dto.batchId, 'batch-id');
      expect(dto.rowNumber, 4);
      expect(dto.field, 'sku');
      expect(dto.code, 'duplicate_sku');
      expect(dto.rawValue, 'RICE-001');
    });

    test('allows null rawValue', () {
      final dto = ImportBatchErrorRestDto.fromJson({
        'id': 'error-id',
        'batchId': 'batch-id',
        'rowNumber': 4,
        'field': 'name',
        'code': 'required',
        'message': 'Name is required.',
        'rawValue': null,
      });

      expect(dto.rawValue, isNull);
    });
  });
}
