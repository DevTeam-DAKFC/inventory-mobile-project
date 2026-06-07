import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_inventory_movement_data_source.dart';
import 'package:inventory_mobile/data/dto/inventory_movement_create_request_dto.dart';
import 'package:inventory_mobile/domain/models/inventory_movement.dart';
import 'package:inventory_mobile/domain/models/inventory_movement_filters.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _response(String path, dynamic data, {int statusCode = 200}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );
}

DioException _badResponse(String path, int statusCode, dynamic data) {
  final requestOptions = RequestOptions(path: path);
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}

Map<String, dynamic> _movementJson({String id = 'movement-id'}) => {
  'id': id,
  'productId': 'product-id',
  'branchId': 'branch-id',
  'userId': 'user-id',
  'type': 'incoming',
  'quantity': 5,
  'previousStock': 10,
  'resultingStock': 15,
  'reason': 'Restock',
  'createdAt': '2026-06-05T12:00:00Z',
};

void main() {
  late _MockDio dio;
  late RestApiInventoryMovementDataSource sut;

  setUp(() {
    dio = _MockDio();
    sut = RestApiInventoryMovementDataSource(dio);
  });

  group('createMovement', () {
    test('posts create request and returns movement DTO', () async {
      const request = InventoryMovementCreateRequestDto(
        productId: 'product-id',
        branchId: 'branch-id',
        type: 'incoming',
        quantity: 5,
        reason: 'Restock',
      );
      when(
        () => dio.post<dynamic>('/inventory-movements', data: request.toJson()),
      ).thenAnswer(
        (_) async =>
            _response('/inventory-movements', _movementJson(), statusCode: 201),
      );

      final dto = await sut.createMovement(request);

      expect(dto.id, 'movement-id');
      expect(dto.resultingStock, 15);
      verify(
        () => dio.post<dynamic>('/inventory-movements', data: request.toJson()),
      ).called(1);
    });

    test('maps insufficient_stock 422 response', () async {
      const request = InventoryMovementCreateRequestDto(
        productId: 'product-id',
        branchId: 'branch-id',
        type: 'outgoing',
        quantity: 999,
        reason: 'Sale',
      );
      when(
        () => dio.post<dynamic>('/inventory-movements', data: request.toJson()),
      ).thenThrow(
        _badResponse('/inventory-movements', 422, {
          'code': 'insufficient_stock',
          'message': 'Not enough stock available.',
        }),
      );

      await expectLater(
        sut.createMovement(request),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.insufficientStock,
          ),
        ),
      );
    });
  });

  group('getMovements', () {
    test('sends supported filters as query parameters', () async {
      final filters = InventoryMovementFilters(
        productId: 'product-id',
        branchId: 'branch-id',
        type: MovementType.outgoing,
        userId: 'user-id',
        from: DateTime.utc(2026, 6, 1),
        to: DateTime.utc(2026, 6, 5),
        page: 2,
        pageSize: 10,
      );
      final expectedQuery = {
        'productId': 'product-id',
        'branchId': 'branch-id',
        'type': 'outgoing',
        'userId': 'user-id',
        'from': '2026-06-01T00:00:00.000Z',
        'to': '2026-06-05T00:00:00.000Z',
        'page': 2,
        'pageSize': 10,
      };
      when(
        () => dio.get<dynamic>(
          '/inventory-movements',
          queryParameters: expectedQuery,
        ),
      ).thenAnswer(
        (_) async => _response('/inventory-movements', {
          'items': [_movementJson()],
          'total': 1,
          'page': 2,
          'pageSize': 10,
          'hasNextPage': false,
        }),
      );

      final dto = await sut.getMovements(filters);

      expect(dto.items, hasLength(1));
      expect(dto.page, 2);
      verify(
        () => dio.get<dynamic>(
          '/inventory-movements',
          queryParameters: expectedQuery,
        ),
      ).called(1);
    });
  });

  group('getMovementById', () {
    test('loads movement detail by id', () async {
      when(
        () => dio.get<dynamic>('/inventory-movements/movement-id'),
      ).thenAnswer(
        (_) async => _response(
          '/inventory-movements/movement-id',
          _movementJson(id: 'movement-id'),
        ),
      );

      final dto = await sut.getMovementById('movement-id');

      expect(dto.id, 'movement-id');
    });
  });
}
