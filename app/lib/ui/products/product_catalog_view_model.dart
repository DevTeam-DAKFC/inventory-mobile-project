import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/app_result.dart';
import '../../data/providers/inventory_movement_providers.dart';
import '../../domain/models/product.dart';
import '../movements/movement_providers.dart';
import 'product_catalog_state.dart';

final productCatalogViewModelProvider =
    NotifierProvider<ProductCatalogViewModel, ProductCatalogState>(
      ProductCatalogViewModel.new,
    );

class ProductCatalogViewModel extends Notifier<ProductCatalogState> {
  @override
  ProductCatalogState build() => const ProductCatalogState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final activeResult = await ref
        .read(productRepositoryProvider)
        .getProducts(isActive: true, page: 1, pageSize: 100);
    final inactiveResult = await ref
        .read(productRepositoryProvider)
        .getProducts(isActive: false, page: 1, pageSize: 100);

    final activeFailure = activeResult.exceptionOrNull;
    final inactiveFailure = inactiveResult.exceptionOrNull;
    if (activeFailure != null || inactiveFailure != null) {
      final exception = activeFailure ?? inactiveFailure!;
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorCode: exception.code,
        errorMessage: exception.message,
      );
      return;
    }

    final products = [
      ...(activeResult.dataOrNull?.items ?? const <Product>[]),
      ...(inactiveResult.dataOrNull?.items ?? const <Product>[]),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    state = state.copyWith(
      products: products,
      isLoading: false,
      hasLoaded: true,
      clearError: true,
    );
  }

  Future<void> activateProduct(String productId) async {
    await _changeProductState(
      productId,
      action: ref.read(productRepositoryProvider).activateProduct,
      successMessage: 'Product activated successfully.',
    );
  }

  Future<void> deactivateProduct(String productId) async {
    await _changeProductState(
      productId,
      action: ref.read(productRepositoryProvider).deactivateProduct,
      successMessage: 'Product deactivated successfully.',
    );
  }

  Future<void> _changeProductState(
    String productId, {
    required Future<AppResult<void>> Function(String productId) action,
    required String successMessage,
  }) async {
    state = state.copyWith(
      isChangingState: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await action(productId);
    final exception = result.exceptionOrNull;
    if (exception != null) {
      state = state.copyWith(
        isChangingState: false,
        errorCode: exception.code,
        errorMessage: exception.message,
      );
      return;
    }

    state = state.copyWith(
      isChangingState: false,
      successMessage: successMessage,
    );
    ref.invalidate(activeProductCatalogProvider);
    ref.invalidate(inactiveProductCatalogProvider);
    await load();
  }
}
