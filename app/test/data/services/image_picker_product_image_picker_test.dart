import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/data/services/image_picker_product_image_picker.dart';

void main() {
  for (final testCase in <(String, String, Uint8List)>[
    ('JPEG', 'image/jpeg', _jpegBytes()),
    ('PNG', 'image/png', _pngBytes()),
    ('WebP', 'image/webp', _webpBytes()),
  ]) {
    test('returns validated ${testCase.$1} selected from gallery', () async {
      final picker = ImagePickerProductImagePicker(
        selectImage: () async =>
            XFile.fromData(testCase.$3, mimeType: testCase.$2),
      );

      final result = await picker.pickFromGallery();

      expect(result.dataOrNull?.fileName, startsWith('product-image.'));
      expect(result.dataOrNull?.mimeType, testCase.$2);
    });
  }

  test('returns success with null when selection is cancelled', () async {
    final picker = ImagePickerProductImagePicker(selectImage: () async => null);

    final result = await picker.pickFromGallery();

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, isNull);
  });

  test('returns validation failure for invalid selected file', () async {
    final picker = ImagePickerProductImagePicker(
      selectImage: () async => XFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        name: 'invalid.jpg',
        mimeType: 'image/jpeg',
      ),
    );

    final result = await picker.pickFromGallery();

    expect(result.exceptionOrNull?.code, AppErrorCode.validationError);
    expect(result.exceptionOrNull?.details?['reason'], 'unsupported_file_type');
  });

  test('returns controlled failure when picker throws', () async {
    final picker = ImagePickerProductImagePicker(
      selectImage: () async => throw StateError('picker failed'),
    );

    final result = await picker.pickFromGallery();

    expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
    expect(
      result.exceptionOrNull?.details?['reason'],
      'image_selection_failed',
    );
  });
}

Uint8List _pngBytes() =>
    Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

Uint8List _jpegBytes() => Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]);

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
