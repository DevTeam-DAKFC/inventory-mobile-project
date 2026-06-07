import '../../core/errors/app_error_code.dart';
import '../../domain/models/product.dart';

final class ProductCatalogState {
  const ProductCatalogState({
    this.products = const [],
    this.isLoading = false,
    this.isChangingState = false,
    this.hasLoaded = false,
    this.errorCode,
    this.errorMessage,
    this.successMessage,
  });

  final List<Product> products;
  final bool isLoading;
  final bool isChangingState;
  final bool hasLoaded;
  final AppErrorCode? errorCode;
  final String? errorMessage;
  final String? successMessage;

  bool get isEmpty => hasLoaded && products.isEmpty && errorMessage == null;

  ProductCatalogState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isChangingState,
    bool? hasLoaded,
    AppErrorCode? errorCode,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProductCatalogState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isChangingState: isChangingState ?? this.isChangingState,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
