import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/product_import_file.dart';

void main() {
  group('ProductImportFile', () {
    test('can be constructed with a file name and bytes', () {
      const file = ProductImportFile(
        fileName: 'products.csv',
        bytes: [110, 97, 109, 101],
      );

      expect(file.fileName, 'products.csv');
      expect(file.bytes, [110, 97, 109, 101]);
    });
  });
}
