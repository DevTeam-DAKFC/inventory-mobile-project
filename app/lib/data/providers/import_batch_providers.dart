import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/import_batch_repository.dart';
import '../datasources/rest/rest_api_import_batch_data_source.dart';
import '../repositories/import_batch_repository_impl.dart';
import 'health_providers.dart';

final importBatchDataSourceProvider = Provider<RestApiImportBatchDataSource>(
  (ref) => RestApiImportBatchDataSource(ref.watch(apiClientProvider).dio),
);

final importBatchRepositoryProvider = Provider<ImportBatchRepository>(
  (ref) => ImportBatchRepositoryImpl(ref.watch(importBatchDataSourceProvider)),
);
