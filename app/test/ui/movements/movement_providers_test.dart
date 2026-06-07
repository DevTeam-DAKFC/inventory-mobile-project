import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/branch_providers.dart';
import 'package:inventory_mobile/data/providers/inventory_movement_providers.dart';
import 'package:inventory_mobile/data/providers/product_providers.dart';
import 'package:inventory_mobile/domain/models/branch.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_filters.dart';
import 'package:inventory_mobile/domain/models/paginated_products.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';
import 'package:inventory_mobile/domain/models/product.dart';
import 'package:inventory_mobile/domain/models/product_list_query.dart';
import 'package:inventory_mobile/domain/models/stock_lookup.dart';
import 'package:inventory_mobile/domain/repositories/branch_repository.dart';
import 'package:inventory_mobile/domain/repositories/inventory_movement_repository.dart';
import 'package:inventory_mobile/domain/repositories/product_repository.dart';
import 'package:inventory_mobile/domain/repositories/stock_lookup_repository.dart';
import 'package:inventory_mobile/ui/movements/movement_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockInventoryMovementRepository extends Mock
    implements InventoryMovementRepository {}

class _MockStockLookupRepository extends Mock
    implements StockLookupRepository {}

class _MockBranchRepository extends Mock implements BranchRepository {}

class _MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late _MockInventoryMovementRepository movementRepository;
  late _MockStockLookupRepository stockLookupRepository;
  late _MockBranchRepository branchRepository;
  late _MockProductRepository productRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const InventoryMovementFilters());
    registerFallbackValue(const ProductListQuery());
  });

  setUp(() {
    movementRepository = _MockInventoryMovementRepository();
    stockLookupRepository = _MockStockLookupRepository();
    branchRepository = _MockBranchRepository();
    productRepository = _MockProductRepository();
    container = ProviderContainer(
      overrides: [
        inventoryMovementRepositoryProvider.overrideWithValue(
          movementRepository,
        ),
        stockLookupRepositoryProvider.overrideWithValue(stockLookupRepository),
        branchRepositoryProvider.overrideWithValue(branchRepository),
        productRepositoryProvider.overrideWithValue(productRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('movementHistoryProvider', () {
    test('loads movement history through the repository', () async {
      const filters = InventoryMovementFilters(page: 2, pageSize: 10);
      const page = PaginatedResult<InventoryMovement>(
        items: [],
        page: 2,
        pageSize: 10,
        totalCount: 0,
      );
      when(
        () => movementRepository.getMovements(filters),
      ).thenAnswer((_) async => const AppSuccess(page));

      final result = await container.read(
        movementHistoryProvider(filters).future,
      );

      expect(result.dataOrNull, page);
      verify(() => movementRepository.getMovements(filters)).called(1);
    });
  });

  group('movementDetailProvider', () {
    test('loads movement detail through the repository', () async {
      final movement = InventoryMovement(
        id: 'movement-id',
        productId: 'product-id',
        branchId: 'branch-id',
        userId: 'user-id',
        type: MovementType.incoming,
        quantity: 5,
        previousStock: 10,
        resultingStock: 15,
        reason: 'Restock',
        createdAt: DateTime.utc(2026, 6, 5, 12),
      );
      when(
        () => movementRepository.getMovementById('movement-id'),
      ).thenAnswer((_) async => AppSuccess(movement));

      final result = await container.read(
        movementDetailProvider('movement-id').future,
      );

      expect(result.dataOrNull, movement);
      verify(() => movementRepository.getMovementById('movement-id')).called(1);
    });
  });

  group('stockLookupProvider', () {
    test('loads stock lookup through the repository', () async {
      const stock = StockLookup(
        id: 'stock-id',
        availableQuantity: 12,
        minStock: 10,
        isLowStock: false,
        product: StockLookupProduct(
          id: 'product-id',
          name: 'Rice 1kg',
          sku: 'RICE-001',
          category: 'Food',
        ),
        branch: StockLookupBranch(id: 'branch-id', name: 'Central Branch'),
      );
      when(
        () => stockLookupRepository.getStockLookup(
          productId: 'product-id',
          branchId: 'branch-id',
        ),
      ).thenAnswer((_) async => const AppSuccess(stock));

      final result = await container.read(
        stockLookupProvider((
          productId: 'product-id',
          branchId: 'branch-id',
        )).future,
      );

      expect(result.dataOrNull, stock);
      verify(
        () => stockLookupRepository.getStockLookup(
          productId: 'product-id',
          branchId: 'branch-id',
        ),
      ).called(1);
    });
  });

  group('activeBranchCatalogProvider', () {
    test('loads active branches through the repository', () async {
      final branches = [
        Branch(
          id: 'central-branch',
          name: 'Central Branch',
          isActive: true,
          createdAt: DateTime.utc(2026, 6, 5),
        ),
      ];
      when(
        () => branchRepository.getBranches(isActive: true),
      ).thenAnswer((_) async => AppSuccess(branches));

      final result = await container.read(activeBranchCatalogProvider.future);

      expect(result.dataOrNull, hasLength(1));
      expect(result.dataOrNull?.single.name, 'Central Branch');
      verify(() => branchRepository.getBranches(isActive: true)).called(1);
    });
  });

  group('activeProductCatalogProvider', () {
    test('loads active products through the repository', () async {
      final products = [
        Product(
          id: 'product-id',
          name: 'Rice 1kg',
          sku: 'RICE-001',
          category: 'Food',
          minStock: 10,
          isActive: true,
          createdAt: DateTime.utc(2026, 6, 5),
        ),
      ];
      const query = ProductListQuery(isActive: true, page: 1, pageSize: 100);
      final page = PaginatedProducts(
        items: products,
        total: 1,
        page: 1,
        pageSize: 100,
        hasNextPage: false,
      );
      when(
        () => productRepository.listProducts(query),
      ).thenAnswer((_) async => AppSuccess(page));

      final result = await container.read(activeProductCatalogProvider.future);

      expect(result.dataOrNull, products);
      verify(() => productRepository.listProducts(query)).called(1);
    });
  });
}
