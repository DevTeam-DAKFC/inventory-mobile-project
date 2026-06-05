import 'package:image_picker/image_picker.dart';

import '../../core/errors/app_error_code.dart';
import '../../core/errors/app_exception.dart';
import '../../core/result/app_result.dart';
import '../../domain/models/product_image_input.dart';
import '../../domain/services/product_image_picker.dart';

typedef GalleryImageSelector = Future<XFile?> Function();

/// Product image selector backed by the installed image_picker package.
final class ImagePickerProductImagePicker implements ProductImagePicker {
  ImagePickerProductImagePicker({GalleryImageSelector? selectImage})
    : _selectImage =
          selectImage ??
          (() => ImagePicker().pickImage(
            source: ImageSource.gallery,
            requestFullMetadata: false,
          ));

  final GalleryImageSelector _selectImage;

  @override
  Future<AppResult<ProductImageInput?>> pickFromGallery() async {
    try {
      final file = await _selectImage();
      if (file == null) return const AppSuccess(null);

      final bytes = await file.readAsBytes();
      final detectedMimeType = ProductImageValidator.detectMimeType(bytes);
      final validation = ProductImageValidator.validate(
        ProductImageInput(
          fileName: _fileName(file, detectedMimeType),
          bytes: bytes,
          mimeType: file.mimeType ?? '',
        ),
      );
      return validation.when(
        success: (image) => AppSuccess<ProductImageInput?>(image),
        failure: AppFailure<ProductImageInput?>.new,
      );
    } on AppException catch (error) {
      return AppFailure(error);
    } catch (error, stack) {
      return AppFailure(
        AppException(
          code: AppErrorCode.unexpected,
          message: 'Could not select the product image.',
          cause: error,
          stackTrace: stack,
          details: const {'reason': 'image_selection_failed'},
        ),
      );
    }
  }

  String _fileName(XFile file, String? detectedMimeType) {
    if (file.name.trim().isNotEmpty) return file.name;

    final normalizedPath = file.path.replaceAll(r'\', '/');
    final pathName = normalizedPath.split('/').last;
    if (pathName.isNotEmpty) return pathName;

    return switch (detectedMimeType) {
      'image/png' => 'product-image.png',
      'image/webp' => 'product-image.webp',
      _ => 'product-image.jpg',
    };
  }
}
