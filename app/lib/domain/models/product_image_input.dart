import 'dart:typed_data';

import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';

/// Widget-independent image data selected for a product upload.
final class ProductImageInput {
  const ProductImageInput({
    required this.fileName,
    required this.bytes,
    required this.mimeType,
  });

  final String fileName;
  final Uint8List bytes;
  final String mimeType;

  int get size => bytes.length;
}

/// Local validation rules for product image uploads.
final class ProductImageValidator {
  const ProductImageValidator._();

  static const int maxSizeBytes = 5 * 1024 * 1024;

  static AppResult<ProductImageInput> validate(ProductImageInput image) {
    if (image.bytes.isEmpty) {
      return _failure('empty_file', 'The selected image is empty.');
    }
    if (image.size > maxSizeBytes) {
      return _failure(
        'file_too_large',
        'The selected image exceeds the 5 MB limit.',
      );
    }

    final detectedMimeType = detectMimeType(image.bytes);
    if (detectedMimeType == null) {
      return _failure(
        'unsupported_file_type',
        'The selected file is not a supported image.',
      );
    }

    return AppSuccess(
      ProductImageInput(
        fileName: image.fileName,
        bytes: image.bytes,
        mimeType: detectedMimeType,
      ),
    );
  }

  static String? detectMimeType(Uint8List bytes) {
    if (_isJpeg(bytes)) return 'image/jpeg';
    if (_isPng(bytes)) return 'image/png';
    if (_isWebP(bytes)) return 'image/webp';
    return null;
  }

  static bool _isJpeg(Uint8List bytes) =>
      bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF;

  static bool _isPng(Uint8List bytes) =>
      bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A;

  static bool _isWebP(Uint8List bytes) =>
      bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50;

  static AppFailure<ProductImageInput> _failure(String reason, String message) {
    return AppFailure(
      AppException(
        code: AppErrorCode.validationError,
        message: message,
        details: {'reason': reason},
      ),
    );
  }
}
