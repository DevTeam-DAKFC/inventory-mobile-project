import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/dto/paginated_import_batch_error_rest_dto.dart';
import 'package:inventory_mobile/data/dto/paginated_import_batch_rest_dto.dart';

void main() {
  group('PaginatedImportBatchRestDto', () {
    test('parses a valid import batch page response', () {
      final dto = PaginatedImportBatchRestDto.fromJson({
        'items': [
          {
            'id': 'batch-id',
            'fileName': 'products.csv',
            'importedBy': 'user-id',
            'status': 'completed',
            'totalRows': 3,
            'processedRows': 3,
            'importedRows': 3,
            'failedRows': 0,
            'createdAt': '2026-06-05T20:00:00Z',
            'completedAt': '2026-06-05T20:01:00Z',
          },
        ],
        'total': 1,
        'page': 1,
        'pageSize': 20,
        'hasNextPage': false,
      });

      expect(dto.items, hasLength(1));
      expect(dto.total, 1);
      expect(dto.hasNextPage, isFalse);
    });

    test('throws AppException for invalid items field', () {
      expect(
        () => PaginatedImportBatchRestDto.fromJson({
          'items': null,
          'total': 1,
          'page': 1,
          'pageSize': 20,
          'hasNextPage': false,
        }),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('PaginatedImportBatchErrorRestDto', () {
    test('parses a valid import batch error page response', () {
      final dto = PaginatedImportBatchErrorRestDto.fromJson({
        'items': [
          {
            'id': 'error-id',
            'batchId': 'batch-id',
            'rowNumber': 2,
            'field': 'minStock',
            'code': 'invalid_min_stock',
            'message': 'Minimum stock must be valid.',
            'rawValue': '-5',
          },
        ],
        'total': 1,
        'page': 1,
        'pageSize': 20,
        'hasNextPage': false,
      });

      expect(dto.items, hasLength(1));
      expect(dto.items.single.field, 'minStock');
      expect(dto.total, 1);
    });
  });
}
