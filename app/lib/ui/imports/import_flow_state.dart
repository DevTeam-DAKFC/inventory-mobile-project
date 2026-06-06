import '../../core/errors/app_error_code.dart';
import '../../domain/models/import_batch.dart';
import '../../domain/models/product_import_file.dart';

final class ImportFlowState {
  const ImportFlowState({
    this.selectedFile,
    this.createdBatch,
    this.batchErrors = const [],
    this.isUploading = false,
    this.isLoadingErrors = false,
    this.errorCode,
    this.errorMessage,
    this.successMessage,
  });

  final ProductImportFile? selectedFile;
  final ImportBatch? createdBatch;
  final List<ImportBatchError> batchErrors;
  final bool isUploading;
  final bool isLoadingErrors;
  final AppErrorCode? errorCode;
  final String? errorMessage;
  final String? successMessage;

  bool get canUpload => selectedFile != null && !isUploading;

  ImportFlowState copyWith({
    ProductImportFile? selectedFile,
    ImportBatch? createdBatch,
    List<ImportBatchError>? batchErrors,
    bool? isUploading,
    bool? isLoadingErrors,
    AppErrorCode? errorCode,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedFile = false,
    bool clearCreatedBatch = false,
    bool clearBatchErrors = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ImportFlowState(
      selectedFile: clearSelectedFile
          ? null
          : selectedFile ?? this.selectedFile,
      createdBatch: clearCreatedBatch
          ? null
          : createdBatch ?? this.createdBatch,
      batchErrors: clearBatchErrors
          ? const []
          : batchErrors ?? this.batchErrors,
      isUploading: isUploading ?? this.isUploading,
      isLoadingErrors: isLoadingErrors ?? this.isLoadingErrors,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
