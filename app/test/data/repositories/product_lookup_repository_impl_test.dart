import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/core/errors/app_error_code.dart';
import 'package:inventory_mobile/core/errors/app_exception.dart';
import 'package:inventory_mobile/core/result/app_result.dart';
import 'package:inventory_mobile/data/datasources/rest/rest_api_product_lookup_data_source.dart';
import 'package:inventory_mobile/data/dto/external_product_suggestion_dto.dart';
import 'package:inventory_mobile/data/repositories/product_lookup_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements RestApiProductLookupDataSource {}

void main() {
  late _MockDataSource dataSource;
  late ProductLookupRepositoryImpl sut;

  setUp(() {
    dataSource = _MockDataSource();
    sut = ProductLookupRepositoryImpl(dataSource);
  });

  test('maps ExternalProductSuggestion DTO to domain', () async {
    when(() => dataSource.lookupByBarcode('3017624010701')).thenAnswer(
      (_) async => const ExternalProductSuggestionDto(
        barcode: '3017624010701',
        name: 'Nutella',
        brand: 'Ferrero',
        category: 'Spreads',
        imageUrl: 'https://example.com/nutella.jpg',
        source: 'open_food_facts',
      ),
    );

    final result = await sut.lookupByBarcode('3017624010701');

    expect(result, isA<AppSuccess>());
    expect(result.dataOrNull?.brand, 'Ferrero');
    expect(result.dataOrNull?.source, 'open_food_facts');
  });

  test('preserves controlled lookup failures', () async {
    const exception = AppException(
      code: AppErrorCode.serviceUnavailable,
      message: 'Unavailable',
    );
    when(
      () => dataSource.lookupByBarcode('3017624010701'),
    ).thenThrow(exception);

    final result = await sut.lookupByBarcode('3017624010701');

    expect(result.exceptionOrNull, same(exception));
  });
}
