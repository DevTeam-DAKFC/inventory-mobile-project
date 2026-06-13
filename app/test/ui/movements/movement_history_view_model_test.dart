import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/providers/inventory_movement_providers.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_create_request.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_filters.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';
import 'package:inventory_mobile/domain/repositories/inventory_movement_repository.dart';
import 'package:inventory_mobile/ui/movements/movement_history_view_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockMovementRepository extends Mock
    implements InventoryMovementRepository {}

InventoryMovement _movement(String id) {
  return InventoryMovement(
    id: id,
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

void main() {
  late _MockMovementRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const InventoryMovementFilters());
    registerFallbackValue(
      const InventoryMovementCreateRequest(
        productId: 'product-id',
        branchId: 'branch-id',
        type: MovementType.incoming,
        quantity: 5,
        reason: 'Restock',
      ),
    );
  });

  setUp(() {
    repository = _MockMovementRepository();
    container = ProviderContainer(
      overrides: [
        inventoryMovementRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loads movement history successfully', () async {
    when(
      () => repository.getMovements(const InventoryMovementFilters()),
    ).thenAnswer(
      (_) async => AppSuccess(
        PaginatedResult(
          items: [_movement('movement-1')],
          page: 1,
          pageSize: 20,
          totalCount: 1,
        ),
      ),
    );

    await container.read(movementHistoryViewModelProvider.notifier).load();

    final state = container.read(movementHistoryViewModelProvider);
    expect(state.hasLoaded, isTrue);
    expect(state.isLoading, isFalse);
    expect(state.movements.single.id, 'movement-1');
    expect(state.totalCount, 1);
  });

  test('handles empty history state', () async {
    when(
      () => repository.getMovements(const InventoryMovementFilters()),
    ).thenAnswer(
      (_) async => const AppSuccess(
        PaginatedResult<InventoryMovement>(
          items: [],
          page: 1,
          pageSize: 20,
          totalCount: 0,
        ),
      ),
    );

    await container.read(movementHistoryViewModelProvider.notifier).load();

    final state = container.read(movementHistoryViewModelProvider);
    expect(state.isEmpty, isTrue);
  });

  test('handles repository failure', () async {
    const exception = AppException(
      code: AppErrorCode.unauthorized,
      message: 'Unauthorized.',
    );
    when(
      () => repository.getMovements(const InventoryMovementFilters()),
    ).thenAnswer((_) async => const AppFailure(exception));

    await container.read(movementHistoryViewModelProvider.notifier).load();

    final state = container.read(movementHistoryViewModelProvider);
    expect(state.hasLoaded, isTrue);
    expect(state.errorCode, AppErrorCode.unauthorized);
    expect(state.errorMessage, 'Unauthorized.');
  });

  test('loads next page and appends movements', () async {
    when(
      () => repository.getMovements(const InventoryMovementFilters()),
    ).thenAnswer(
      (_) async => AppSuccess(
        PaginatedResult(
          items: [_movement('movement-1')],
          page: 1,
          pageSize: 20,
          totalCount: 25,
        ),
      ),
    );
    when(
      () => repository.getMovements(
        any(
          that: isA<InventoryMovementFilters>().having(
            (filters) => filters.page,
            'page',
            2,
          ),
        ),
      ),
    ).thenAnswer(
      (_) async => AppSuccess(
        PaginatedResult(
          items: [_movement('movement-2')],
          page: 2,
          pageSize: 20,
          totalCount: 25,
        ),
      ),
    );

    final viewModel = container.read(movementHistoryViewModelProvider.notifier);
    await viewModel.load();
    await viewModel.loadNextPage();

    final state = container.read(movementHistoryViewModelProvider);
    expect(state.movements.map((movement) => movement.id), [
      'movement-1',
      'movement-2',
    ]);
    expect(state.filters.page, 2);
  });
}
