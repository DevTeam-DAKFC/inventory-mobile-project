import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/import_batch.dart';

void main() {
  group('ImportStatus', () {
    test('exposes pending, validated, completed and failed', () {
      expect(ImportStatus.values, [
        ImportStatus.pending,
        ImportStatus.validated,
        ImportStatus.completed,
        ImportStatus.failed,
      ]);
    });
  });

  group('ImportBatchError', () {
    test('can be constructed with required fields', () {
      const error = ImportBatchError(
        rowNumber: 3,
        field: 'initialStock',
        message: 'Initial stock cannot be negative.',
      );

      expect(error.rowNumber, 3);
      expect(error.field, 'initialStock');
      expect(error.message, 'Initial stock cannot be negative.');
    });
  });

  group('ImportBatch', () {
    test('can be constructed with required fields', () {
      final createdAt = DateTime.utc(2026, 6, 2, 20);
      final batch = ImportBatch(
        id: 'import_001',
        fileName: 'inventory_initial.csv',
        status: ImportStatus.pending,
        totalRows: 4,
        validRows: 4,
        invalidRows: 0,
        importedBy: 'user_admin_001',
        errors: const [],
        createdAt: createdAt,
      );

      expect(batch.id, 'import_001');
      expect(batch.fileName, 'inventory_initial.csv');
      expect(batch.status, ImportStatus.pending);
      expect(batch.totalRows, 4);
      expect(batch.validRows, 4);
      expect(batch.invalidRows, 0);
      expect(batch.importedBy, 'user_admin_001');
      expect(batch.errors, isEmpty);
      expect(batch.createdAt, createdAt);
      expect(batch.completedAt, isNull);
    });

    test('preserves errors list and completedAt', () {
      const errors = [
        ImportBatchError(
          rowNumber: 1,
          field: 'name',
          message: 'Name is required.',
        ),
        ImportBatchError(
          rowNumber: 3,
          field: 'initialStock',
          message: 'Initial stock cannot be negative.',
        ),
      ];
      final completedAt = DateTime.utc(2026, 6, 2, 20, 12);
      final batch = ImportBatch(
        id: 'import_002',
        fileName: 'inventory_with_errors.csv',
        status: ImportStatus.failed,
        totalRows: 4,
        validRows: 0,
        invalidRows: 4,
        importedBy: 'user_admin_001',
        errors: errors,
        createdAt: DateTime.utc(2026, 6, 2, 20, 10),
        completedAt: completedAt,
      );

      expect(batch.status, ImportStatus.failed);
      expect(batch.errors, errors);
      expect(batch.errors.length, 2);
      expect(batch.errors[0].rowNumber, 1);
      expect(batch.errors[1].field, 'initialStock');
      expect(batch.completedAt, completedAt);
    });
  });
}
