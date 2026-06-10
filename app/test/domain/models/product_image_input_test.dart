import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/domain/models/product_image_input.dart';

void main() {
  group('ProductImageValidator', () {
    for (final testCase in <(String, String, Uint8List)>[
      ('JPEG', 'image/jpeg', _jpegBytes()),
      ('PNG', 'image/png', _pngBytes()),
      ('WebP', 'image/webp', _webpBytes()),
    ]) {
      test('accepts valid ${testCase.$1}', () {
        final result = ProductImageValidator.validate(
          ProductImageInput(
            fileName: 'product.bin',
            bytes: testCase.$3,
            mimeType: 'application/octet-stream',
          ),
        );

        expect(result.dataOrNull?.mimeType, testCase.$2);
        expect(result.dataOrNull?.size, testCase.$3.length);
      });
    }

    test('rejects an empty file', () {
      final result = ProductImageValidator.validate(
        ProductImageInput(
          fileName: 'empty.jpg',
          bytes: Uint8List(0),
          mimeType: 'image/jpeg',
        ),
      );

      expect(result.exceptionOrNull?.code, AppErrorCode.validationError);
      expect(result.exceptionOrNull?.details?['reason'], 'empty_file');
    });

    test('rejects a file larger than 5 MB', () {
      final result = ProductImageValidator.validate(
        ProductImageInput(
          fileName: 'large.jpg',
          bytes: Uint8List(ProductImageValidator.maxSizeBytes + 1),
          mimeType: 'image/jpeg',
        ),
      );

      expect(result.exceptionOrNull?.details?['reason'], 'file_too_large');
    });

    test('rejects an unsupported file type', () {
      final result = ProductImageValidator.validate(
        ProductImageInput(
          fileName: 'text.jpg',
          bytes: Uint8List.fromList('not an image'.codeUnits),
          mimeType: 'image/jpeg',
        ),
      );

      expect(
        result.exceptionOrNull?.details?['reason'],
        'unsupported_file_type',
      );
    });
  });
}

Uint8List _jpegBytes() => Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]);

Uint8List _pngBytes() =>
    Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

Uint8List _webpBytes() => Uint8List.fromList([
  0x52,
  0x49,
  0x46,
  0x46,
  0,
  0,
  0,
  0,
  0x57,
  0x45,
  0x42,
  0x50,
]);
