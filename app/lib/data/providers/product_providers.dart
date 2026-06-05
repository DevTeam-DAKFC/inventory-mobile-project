import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/product_repository.dart';
import '../datasources/rest/rest_api_product_data_source.dart';
import '../repositories/product_repository_impl.dart';
import 'health_providers.dart';

final productDataSourceProvider = Provider<RestApiProductDataSource>(
  (ref) => RestApiProductDataSource(ref.watch(apiClientProvider).dio),
);

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.watch(productDataSourceProvider)),
);
