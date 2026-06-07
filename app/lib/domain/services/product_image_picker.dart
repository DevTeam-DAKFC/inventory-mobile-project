import '../../core/result/app_result.dart';
import '../models/product_image_input.dart';

/// Selects product images without exposing platform picker types.
abstract class ProductImagePicker {
  Future<AppResult<ProductImageInput?>> pickFromGallery();
}
