import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/inventory_movement_providers.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_create_request.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_filters.dart';
import 'package:inventory_mobile/domain/models/stock_lookup.dart';
import 'package:inventory_mobile/domain/repositories/inventory_movement_repository.dart';
import 'package:inventory_mobile/domain/repositories/stock_lookup_repository.dart';
import 'package:inventory_mobile/ui/movements/movement_form_view_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockMovementRepository extends Mock
    implements InventoryMovementRepository {}

class _MockStockLookupRepository extends Mock
    implements StockLookupRepository {}

InventoryMovement _movement() {
  return InventoryMovement(
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
}

const _stock = StockLookup(
  id: 'stock-id',
  availableQuantity: 15,
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

void main() {
  late _MockMovementRepository movementRepository;
  late _MockStockLookupRepository stockLookupRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const InventoryMovementCreateRequest(
        productId: 'product-id',
        branchId: 'branch-id',
        type: MovementType.incoming,
        quantity: 5,
        reason: 'Restock',
      ),
    );
    registerFallbackValue(const InventoryMovementFilters());
  });

  setUp(() {
    movementRepository = _MockMovementRepository();
    stockLookupRepository = _MockStockLookupRepository();
    container = ProviderContainer(
      overrides: [
        inventoryMovementRepositoryProvider.overrideWithValue(
          movementRepository,
        ),
        stockLookupRepositoryProvider.overrideWithValue(stockLookupRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('validates required fields before submit', () async {
    final viewModel = container.read(movementFormViewModelProvider.notifier);

    await viewModel.submit();

    final state = container.read(movementFormViewModelProvider);
    expect(state.errorCode, AppErrorCode.validationError);
    expect(
      state.fieldErrors.keys,
      containsAll([
        MovementFormViewModel.productField,
        MovementFormViewModel.branchField,
        MovementFormViewModel.quantityField,
        MovementFormViewModel.reasonField,
      ]),
    );
    verifyNever(() => movementRepository.createMovement(any()));
  });

  test('creates movement and refreshes stock from backend lookup', () async {
    when(
      () => movementRepository.createMovement(any()),
    ).thenAnswer((_) async => AppSuccess(_movement()));
    when(
      () => stockLookupRepository.getStockLookup(
        productId: 'product-id',
        branchId: 'branch-id',
      ),
    ).thenAnswer((_) async => const AppSuccess(_stock));

    final viewModel = container.read(movementFormViewModelProvider.notifier)
      ..setProductId('product-id')
      ..setBranchId('branch-id')
      ..setQuantity(5)
      ..setReason('Restock');

    await viewModel.submit();

    final state = container.read(movementFormViewModelProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.createdMovement?.id, 'movement-id');
    expect(state.currentStock?.availableQuantity, 15);
    expect(state.successMessage, 'Movement registered successfully.');
    verify(() => movementRepository.createMovement(any())).called(1);
    verify(
      () => stockLookupRepository.getStockLookup(
        productId: 'product-id',
        branchId: 'branch-id',
      ),
    ).called(1);
  });

  test('shows a clear insufficient stock error', () async {
    const exception = AppException(
      code: AppErrorCode.insufficientStock,
      message: 'Backend insufficient stock message.',
    );
    when(
      () => movementRepository.createMovement(any()),
    ).thenAnswer((_) async => const AppFailure(exception));

    final viewModel = container.read(movementFormViewModelProvider.notifier)
      ..setProductId('product-id')
      ..setBranchId('branch-id')
      ..setType(MovementType.outgoing)
      ..setQuantity(999)
      ..setReason('Sale');

    await viewModel.submit();

    final state = container.read(movementFormViewModelProvider);
    expect(state.errorCode, AppErrorCode.insufficientStock);
    expect(
      state.errorMessage,
      'Not enough stock available to register this movement.',
    );
    verifyNever(
      () => stockLookupRepository.getStockLookup(
        productId: any(named: 'productId'),
        branchId: any(named: 'branchId'),
      ),
    );
  });

  test('loads current stock for selected product and branch', () async {
    when(
      () => stockLookupRepository.getStockLookup(
        productId: 'product-id',
        branchId: 'branch-id',
      ),
    ).thenAnswer((_) async => const AppSuccess(_stock));

    final viewModel = container.read(movementFormViewModelProvider.notifier)
      ..setProductId('product-id')
      ..setBranchId('branch-id');

    await viewModel.loadCurrentStock();

    final state = container.read(movementFormViewModelProvider);
    expect(state.currentStock, _stock);
    expect(state.isLoadingStock, isFalse);
  });
}
