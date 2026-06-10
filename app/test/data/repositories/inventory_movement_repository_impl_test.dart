import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_inventory_movement_data_source.dart';
import 'package:inventory_mobile/data/dto/inventory_movement_create_request_dto.dart';
import 'package:inventory_mobile/data/dto/inventory_movement_rest_dto.dart';
import 'package:inventory_mobile/data/dto/paginated_inventory_movement_rest_dto.dart';
import 'package:inventory_mobile/data/repositories/inventory_movement_repository_impl.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_create_request.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_filters.dart';
import 'package:inventory_mobile/domain/models/paginated_result.dart';
import 'package:mocktail/mocktail.dart';

class _MockMovementDataSource extends Mock
    implements RestApiInventoryMovementDataSource {}

InventoryMovementRestDto _movementDto({String type = 'incoming'}) {
  return InventoryMovementRestDto(
    id: 'movement-id',
    productId: 'product-id',
    branchId: 'branch-id',
    userId: 'user-id',
    type: type,
    quantity: 5,
    previousStock: 10,
    resultingStock: 15,
    reason: 'Restock',
    createdAt: DateTime.utc(2026, 6, 5, 12),
  );
}

void main() {
  late _MockMovementDataSource dataSource;
  late InventoryMovementRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(
      const InventoryMovementCreateRequestDto(
        productId: 'product-id',
        branchId: 'branch-id',
        type: 'incoming',
        quantity: 5,
        reason: 'Restock',
      ),
    );
    registerFallbackValue(const InventoryMovementFilters());
  });

  setUp(() {
    dataSource = _MockMovementDataSource();
    sut = InventoryMovementRepositoryImpl(dataSource);
  });

  group('createMovement', () {
    test('returns AppSuccess with mapped movement', () async {
      when(
        () => dataSource.createMovement(any()),
      ).thenAnswer((_) async => _movementDto());

      final result = await sut.createMovement(
        const InventoryMovementCreateRequest(
          productId: 'product-id',
          branchId: 'branch-id',
          type: MovementType.incoming,
          quantity: 5,
          reason: 'Restock',
        ),
      );

      expect(result, isA<AppSuccess<InventoryMovement>>());
      expect(result.dataOrNull?.type, MovementType.incoming);
      expect(result.dataOrNull?.resultingStock, 15);
    });

    test('preserves AppException failures from the data source', () async {
      const exception = AppException(
        code: AppErrorCode.insufficientStock,
        message: 'Not enough stock available.',
      );
      when(() => dataSource.createMovement(any())).thenThrow(exception);

      final result = await sut.createMovement(
        const InventoryMovementCreateRequest(
          productId: 'product-id',
          branchId: 'branch-id',
          type: MovementType.outgoing,
          quantity: 999,
          reason: 'Sale',
        ),
      );

      expect(result, isA<AppFailure<InventoryMovement>>());
      expect(result.exceptionOrNull, same(exception));
    });
  });

  group('getMovements', () {
    test('returns AppSuccess with mapped paginated movements', () async {
      when(() => dataSource.getMovements(any())).thenAnswer(
        (_) async => PaginatedInventoryMovementRestDto(
          items: [_movementDto(type: 'outgoing')],
          total: 1,
          page: 1,
          pageSize: 20,
          hasNextPage: false,
        ),
      );

      final result = await sut.getMovements(const InventoryMovementFilters());

      expect(result, isA<AppSuccess<PaginatedResult<InventoryMovement>>>());
      expect(result.dataOrNull?.items.single.type, MovementType.outgoing);
      expect(result.dataOrNull?.totalCount, 1);
    });
  });

  group('getMovementById', () {
    test('returns AppFailure unexpected for non-AppException errors', () async {
      when(
        () => dataSource.getMovementById('movement-id'),
      ).thenThrow(StateError('boom'));

      final result = await sut.getMovementById('movement-id');

      expect(result, isA<AppFailure<InventoryMovement>>());
      expect(result.exceptionOrNull?.code, AppErrorCode.unexpected);
      expect(result.exceptionOrNull?.cause, isA<StateError>());
    });
  });
}
