import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/inventory_movement_providers.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';
import 'package:inventory_mobile/domain/models/product.dart';
import 'package:inventory_mobile/domain/repositories/product_repository.dart';
import 'package:inventory_mobile/ui/products/product_catalog_view_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

Product _product({
  required String id,
  required String name,
  required bool isActive,
}) {
  return Product(
    id: id,
    name: name,
    sku: '$id-sku',
    category: 'Food',
    minStock: 10,
    isActive: isActive,
    createdAt: DateTime.utc(2026, 6, 5),
  );
}

void main() {
  late _MockProductRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockProductRepository();
    container = ProviderContainer(
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  void stubProductLists({
    List<Product> active = const [],
    List<Product> inactive = const [],
  }) {
    when(
      () => repository.getProducts(isActive: true, page: 1, pageSize: 100),
    ).thenAnswer(
      (_) async => AppSuccess(
        PaginatedResult(
          items: active,
          page: 1,
          pageSize: 100,
          totalCount: active.length,
        ),
      ),
    );
    when(
      () => repository.getProducts(isActive: false, page: 1, pageSize: 100),
    ).thenAnswer(
      (_) async => AppSuccess(
        PaginatedResult(
          items: inactive,
          page: 1,
          pageSize: 100,
          totalCount: inactive.length,
        ),
      ),
    );
  }

  test('loads active and inactive products', () async {
    final active = _product(id: 'rice', name: 'Rice 1kg', isActive: true);
    final inactive = _product(id: 'beans', name: 'Beans 900g', isActive: false);
    stubProductLists(active: [active], inactive: [inactive]);

    final viewModel = container.read(productCatalogViewModelProvider.notifier);

    await viewModel.load();

    final state = container.read(productCatalogViewModelProvider);
    expect(state.isLoading, isFalse);
    expect(state.products, [inactive, active]);
    expect(state.hasLoaded, isTrue);
  });

  test('deactivates product and refreshes catalog', () async {
    final active = _product(id: 'rice', name: 'Rice 1kg', isActive: true);
    stubProductLists(active: [active]);
    when(
      () => repository.deactivateProduct('rice'),
    ).thenAnswer((_) async => const AppSuccess(null));

    final viewModel = container.read(productCatalogViewModelProvider.notifier);

    await viewModel.deactivateProduct('rice');

    final state = container.read(productCatalogViewModelProvider);
    expect(state.successMessage, 'Product deactivated successfully.');
    verify(() => repository.deactivateProduct('rice')).called(1);
    verify(
      () => repository.getProducts(isActive: true, page: 1, pageSize: 100),
    ).called(1);
  });

  test('shows activate failure', () async {
    const exception = AppException(
      code: AppErrorCode.notFound,
      message: 'Product not found.',
    );
    when(
      () => repository.activateProduct('rice'),
    ).thenAnswer((_) async => const AppFailure(exception));

    final viewModel = container.read(productCatalogViewModelProvider.notifier);

    await viewModel.activateProduct('rice');

    final state = container.read(productCatalogViewModelProvider);
    expect(state.errorCode, AppErrorCode.notFound);
    expect(state.errorMessage, 'Product not found.');
  });
}
