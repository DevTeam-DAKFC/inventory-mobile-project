import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/app_result.dart';
import '../../data/providers/import_batch_providers.dart';
import '../../domain/models/import_batch.dart';
import '../../domain/models/paginated_result.dart';

typedef ImportBatchPageRequest = ({int page, int pageSize});

typedef ImportBatchErrorPageRequest = ({
  String batchId,
  int page,
  int pageSize,
});

final importBatchListProvider =
    FutureProvider.family<
      AppResult<PaginatedResult<ImportBatch>>,
      ImportBatchPageRequest
    >(
      (ref, request) => ref
          .watch(importBatchRepositoryProvider)
          .getImportBatches(page: request.page, pageSize: request.pageSize),
    );

final importBatchDetailProvider =
    FutureProvider.family<AppResult<ImportBatch>, String>(
      (ref, batchId) =>
          ref.watch(importBatchRepositoryProvider).getImportBatchById(batchId),
    );

final importBatchErrorsProvider =
    FutureProvider.family<
      AppResult<PaginatedResult<ImportBatchError>>,
      ImportBatchErrorPageRequest
    >(
      (ref, request) => ref
          .watch(importBatchRepositoryProvider)
          .getImportBatchErrors(
            request.batchId,
            page: request.page,
            pageSize: request.pageSize,
          ),
    );
