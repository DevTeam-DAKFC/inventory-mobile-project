import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/import_batch.dart';

void main() {
  group('ImportStatus', () {
    test('exposes backend CSV import lifecycle states', () {
      expect(ImportStatus.values, [
        ImportStatus.pending,
        ImportStatus.processing,
        ImportStatus.completed,
        ImportStatus.failed,
        ImportStatus.completedWithErrors,
      ]);
    });
  });

  group('ImportBatchError', () {
    test('can be constructed with required fields', () {
      const error = ImportBatchError(
        id: 'error-id',
        batchId: 'batch-id',
        rowNumber: 3,
        field: 'minStock',
        code: 'invalid_min_stock',
        message: 'Minimum stock must be greater than or equal to zero.',
        rawValue: '-1',
      );

      expect(error.id, 'error-id');
      expect(error.batchId, 'batch-id');
      expect(error.rowNumber, 3);
      expect(error.field, 'minStock');
      expect(error.code, 'invalid_min_stock');
      expect(
        error.message,
        'Minimum stock must be greater than or equal to zero.',
      );
      expect(error.rawValue, '-1');
    });
  });

  group('ImportBatch', () {
    test('can be constructed with required fields', () {
      final createdAt = DateTime.utc(2026, 6, 2, 20);
      final batch = ImportBatch(
        id: 'import_001',
        fileName: 'inventory_initial.csv',
        importedBy: 'user_admin_001',
        status: ImportStatus.pending,
        totalRows: 4,
        processedRows: 0,
        importedRows: 0,
        failedRows: 0,
        createdAt: createdAt,
      );

      expect(batch.id, 'import_001');
      expect(batch.fileName, 'inventory_initial.csv');
      expect(batch.importedBy, 'user_admin_001');
      expect(batch.status, ImportStatus.pending);
      expect(batch.totalRows, 4);
      expect(batch.processedRows, 0);
      expect(batch.importedRows, 0);
      expect(batch.failedRows, 0);
      expect(batch.hasErrors, isFalse);
      expect(batch.createdAt, createdAt);
      expect(batch.completedAt, isNull);
    });

    test('preserves completedAt and derives error availability', () {
      final completedAt = DateTime.utc(2026, 6, 2, 20, 12);
      final batch = ImportBatch(
        id: 'import_002',
        fileName: 'inventory_with_errors.csv',
        importedBy: 'user_admin_001',
        status: ImportStatus.completedWithErrors,
        totalRows: 4,
        processedRows: 4,
        importedRows: 2,
        failedRows: 2,
        createdAt: DateTime.utc(2026, 6, 2, 20, 10),
        completedAt: completedAt,
      );

      expect(batch.status, ImportStatus.completedWithErrors);
      expect(batch.processedRows, 4);
      expect(batch.importedRows, 2);
      expect(batch.failedRows, 2);
      expect(batch.hasErrors, isTrue);
      expect(batch.completedAt, completedAt);
    });
  });
}
