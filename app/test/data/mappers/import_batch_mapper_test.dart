import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/import_batch_rest_dto.dart';
import 'package:inventory_mobile/data/dto/paginated_import_batch_error_rest_dto.dart';
import 'package:inventory_mobile/data/dto/paginated_import_batch_rest_dto.dart';
import 'package:inventory_mobile/data/mappers/import_batch_mapper.dart';
import 'package:inventory_mobile/domain/models/import_batch.dart';

void main() {
  group('ImportBatchMapper', () {
    test('maps import batch DTO to domain model', () {
      final dto = ImportBatchRestDto(
        id: 'batch-id',
        fileName: 'products.csv',
        importedBy: 'user-id',
        status: 'completed_with_errors',
        totalRows: 10,
        processedRows: 10,
        importedRows: 8,
        failedRows: 2,
        createdAt: DateTime.utc(2026, 6, 5, 20),
        completedAt: DateTime.utc(2026, 6, 5, 20, 1),
      );

      final domain = ImportBatchMapper.toDomain(dto);

      expect(domain.id, 'batch-id');
      expect(domain.status, ImportStatus.completedWithErrors);
      expect(domain.importedRows, 8);
      expect(domain.failedRows, 2);
      expect(domain.hasErrors, isTrue);
    });

    test('maps import batch error DTO to domain model', () {
      const dto = ImportBatchErrorRestDto(
        id: 'error-id',
        batchId: 'batch-id',
        rowNumber: 3,
        field: 'sku',
        code: 'duplicate_sku',
        message: 'SKU already exists.',
        rawValue: 'RICE-001',
      );

      final domain = ImportBatchMapper.errorToDomain(dto);

      expect(domain.id, 'error-id');
      expect(domain.batchId, 'batch-id');
      expect(domain.rowNumber, 3);
      expect(domain.code, 'duplicate_sku');
      expect(domain.rawValue, 'RICE-001');
    });

    test('maps paginated import batch DTO to domain model', () {
      final dto = PaginatedImportBatchRestDto(
        items: [
          ImportBatchRestDto(
            id: 'batch-id',
            fileName: 'products.csv',
            importedBy: 'user-id',
            status: 'completed',
            totalRows: 1,
            processedRows: 1,
            importedRows: 1,
            failedRows: 0,
            createdAt: DateTime.utc(2026, 6, 5, 20),
          ),
        ],
        total: 1,
        page: 1,
        pageSize: 20,
        hasNextPage: false,
      );

      final domain = ImportBatchMapper.toPaginatedDomain(dto);

      expect(domain.items, hasLength(1));
      expect(domain.items.single.status, ImportStatus.completed);
      expect(domain.totalCount, 1);
    });

    test('maps paginated import batch error DTO to domain model', () {
      const dto = PaginatedImportBatchErrorRestDto(
        items: [
          ImportBatchErrorRestDto(
            id: 'error-id',
            batchId: 'batch-id',
            rowNumber: 2,
            field: 'name',
            code: 'required',
            message: 'Name is required.',
          ),
        ],
        total: 1,
        page: 1,
        pageSize: 20,
        hasNextPage: false,
      );

      final domain = ImportBatchMapper.errorsToPaginatedDomain(dto);

      expect(domain.items, hasLength(1));
      expect(domain.items.single.field, 'name');
      expect(domain.totalCount, 1);
    });

    test('throws AppException for unknown import status', () {
      final dto = ImportBatchRestDto(
        id: 'batch-id',
        fileName: 'products.csv',
        importedBy: 'user-id',
        status: 'unknown',
        totalRows: 1,
        processedRows: 1,
        importedRows: 0,
        failedRows: 1,
        createdAt: DateTime.utc(2026, 6, 5, 20),
      );

      expect(
        () => ImportBatchMapper.toDomain(dto),
        throwsA(isA<AppException>()),
      );
    });
  });
}
