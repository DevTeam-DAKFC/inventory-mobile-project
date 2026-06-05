import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/stock_repository.dart';
import '../datasources/rest/rest_api_stock_data_source.dart';
import '../repositories/stock_repository_impl.dart';
import 'health_providers.dart';

final stockDataSourceProvider = Provider<RestApiStockDataSource>(
  (ref) => RestApiStockDataSource(ref.watch(apiClientProvider).dio),
);

final stockRepositoryProvider = Provider<StockRepository>(
  (ref) => StockRepositoryImpl(ref.watch(stockDataSourceProvider)),
);
