import '../../core/result/app_result.dart';
import '../models/import_batch.dart';
import '../models/paginated_result.dart';
import '../models/product_import_file.dart';

abstract class ImportBatchRepository {
  Future<AppResult<ImportBatch>> uploadProductCsv(ProductImportFile file);

  Future<AppResult<PaginatedResult<ImportBatch>>> getImportBatches({
    int page = 1,
    int pageSize = 20,
  });

  Future<AppResult<ImportBatch>> getImportBatchById(String batchId);

  Future<AppResult<PaginatedResult<ImportBatchError>>> getImportBatchErrors(
    String batchId, {
    int page = 1,
    int pageSize = 20,
  });
}
