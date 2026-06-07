import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';

void main() {
  group('PaginatedResult', () {
    test('detects empty pages', () {
      const result = PaginatedResult<String>(
        items: [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
      );

      expect(result.isEmpty, isTrue);
      expect(result.hasNextPage, isFalse);
    });

    test('detects when another page is available', () {
      const result = PaginatedResult<String>(
        items: ['a', 'b'],
        page: 1,
        pageSize: 2,
        totalCount: 5,
      );

      expect(result.isEmpty, isFalse);
      expect(result.hasNextPage, isTrue);
    });
  });
}
