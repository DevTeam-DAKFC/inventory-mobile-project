import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/providers/product_providers.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_list_query.dart';

enum ProductCatalogFilter { all, active, lowStock }

final class ProductCatalogState {
  const ProductCatalogState({
    this.products = const [],
    this.query = '',
    this.filter = ProductCatalogFilter.all,
    this.page = 0,
    this.hasNextPage = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.loadMoreError,
  });

  final List<Product> products;
  final String query;
  final ProductCatalogFilter filter;
  final int page;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingMore;
  final AppException? error;
  final AppException? loadMoreError;

  bool get isEmpty => !isLoading && error == null && products.isEmpty;

  ProductCatalogState copyWith({
    List<Product>? products,
    String? query,
    ProductCatalogFilter? filter,
    int? page,
    bool? hasNextPage,
    bool? isLoading,
    bool? isLoadingMore,
    AppException? error,
    AppException? loadMoreError,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return ProductCatalogState(
      products: products ?? this.products,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : error ?? this.error,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
    );
  }
}

final productCatalogProvider =
    NotifierProvider<ProductCatalogController, ProductCatalogState>(
      ProductCatalogController.new,
    );

final class ProductCatalogController extends Notifier<ProductCatalogState> {
  static const pageSize = 20;
  static const searchDebounce = Duration(milliseconds: 350);

  Timer? _searchTimer;
  int _requestGeneration = 0;

  @override
  ProductCatalogState build() {
    ref.onDispose(() => _searchTimer?.cancel());
    return const ProductCatalogState();
  }

  Future<void> loadInitial() async {
    if (state.isLoading || state.products.isNotEmpty) return;
    await _loadFirstPage();
  }

  Future<void> reload() => _loadFirstPage();

  void setSearchQuery(String query) {
    _requestGeneration++;
    state = state.copyWith(query: query);
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDebounce, _loadFirstPage);
  }

  Future<void> setFilter(ProductCatalogFilter filter) async {
    if (state.filter == filter) return;
    _searchTimer?.cancel();
    state = state.copyWith(filter: filter);
    await _loadFirstPage();
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasNextPage ||
        state.products.isEmpty) {
      return;
    }

    final generation = _requestGeneration;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, clearLoadMoreError: true);

    final result = await ref
        .read(productRepositoryProvider)
        .listProducts(_buildQuery(nextPage));

    if (generation != _requestGeneration) return;

    result.when(
      success: (page) {
        final productsById = {
          for (final product in state.products) product.id: product,
          for (final product in page.items) product.id: product,
        };
        state = state.copyWith(
          products: productsById.values.toList(growable: false),
          page: page.page,
          hasNextPage: page.hasNextPage,
          isLoadingMore: false,
          clearLoadMoreError: true,
        );
      },
      failure: (exception) {
        state = state.copyWith(isLoadingMore: false, loadMoreError: exception);
      },
    );
  }

  Future<void> _loadFirstPage() async {
    final generation = ++_requestGeneration;
    state = state.copyWith(
      products: const [],
      page: 0,
      hasNextPage: false,
      isLoading: true,
      isLoadingMore: false,
      clearError: true,
      clearLoadMoreError: true,
    );

    final result = await ref
        .read(productRepositoryProvider)
        .listProducts(_buildQuery(1));

    if (generation != _requestGeneration) return;

    result.when(
      success: (page) {
        state = state.copyWith(
          products: page.items,
          page: page.page,
          hasNextPage: page.hasNextPage,
          isLoading: false,
          clearError: true,
        );
      },
      failure: (exception) {
        state = state.copyWith(isLoading: false, error: exception);
      },
    );
  }

  ProductListQuery _buildQuery(int page) {
    final query = state.query.trim();
    return ProductListQuery(
      q: query.isEmpty ? null : query,
      isActive: state.filter == ProductCatalogFilter.active ? true : null,
      lowStockOnly: state.filter == ProductCatalogFilter.lowStock ? true : null,
      page: page,
      pageSize: pageSize,
    );
  }
}
