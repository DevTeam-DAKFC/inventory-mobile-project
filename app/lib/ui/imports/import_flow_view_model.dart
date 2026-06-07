import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error_code.dart';
import '../../data/providers/import_batch_providers.dart';
import '../../domain/models/import_batch.dart';
import '../../domain/models/product_import_file.dart';
import 'import_flow_state.dart';
import 'import_providers.dart';

final importFlowViewModelProvider =
    NotifierProvider.autoDispose<ImportFlowViewModel, ImportFlowState>(
      ImportFlowViewModel.new,
    );

class ImportFlowViewModel extends Notifier<ImportFlowState> {
  @override
  ImportFlowState build() => const ImportFlowState();

  void selectFile(ProductImportFile file) {
    final validationMessage = _validateFile(file);
    if (validationMessage != null) {
      state = state.copyWith(
        errorCode: AppErrorCode.validationError,
        errorMessage: validationMessage,
        clearSelectedFile: true,
        clearCreatedBatch: true,
        clearBatchErrors: true,
        clearSuccess: true,
      );
      return;
    }

    state = state.copyWith(
      selectedFile: file,
      clearCreatedBatch: true,
      clearBatchErrors: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  void clear() {
    state = const ImportFlowState();
  }

  Future<void> submit() async {
    final file = state.selectedFile;
    if (file == null) {
      state = state.copyWith(
        errorCode: AppErrorCode.validationError,
        errorMessage: 'Please select a CSV file before uploading.',
        clearSuccess: true,
      );
      return;
    }

    final validationMessage = _validateFile(file);
    if (validationMessage != null) {
      state = state.copyWith(
        errorCode: AppErrorCode.validationError,
        errorMessage: validationMessage,
        clearSuccess: true,
      );
      return;
    }

    state = state.copyWith(
      isUploading: true,
      clearCreatedBatch: true,
      clearBatchErrors: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await ref
        .read(importBatchRepositoryProvider)
        .uploadProductCsv(file);

    await result.when(
      success: (batch) async {
        state = state.copyWith(
          isUploading: false,
          createdBatch: batch,
          clearSelectedFile: true,
          successMessage: batch.status == ImportStatus.completed
              ? 'Importación completada correctamente.'
              : null,
        );

        if (batch.hasErrors) {
          await loadErrors(batch.id);
        }

        ref.invalidate(importBatchListProvider);
      },
      failure: (exception) async {
        state = state.copyWith(
          isUploading: false,
          errorCode: exception.code,
          errorMessage: exception.message,
        );
      },
    );
  }

  Future<void> loadErrors(String batchId) async {
    state = state.copyWith(isLoadingErrors: true, clearError: true);

    final result = await ref
        .read(importBatchRepositoryProvider)
        .getImportBatchErrors(batchId);

    result.when(
      success: (page) {
        state = state.copyWith(isLoadingErrors: false, batchErrors: page.items);
      },
      failure: (exception) {
        state = state.copyWith(
          isLoadingErrors: false,
          errorCode: exception.code,
          errorMessage: exception.message,
        );
      },
    );
  }

  String? _validateFile(ProductImportFile file) {
    final fileName = file.fileName.trim();
    if (fileName.isEmpty) {
      return 'The selected file must have a name.';
    }
    if (!fileName.toLowerCase().endsWith('.csv')) {
      return 'Only CSV files can be uploaded.';
    }
    if (file.bytes.isEmpty) {
      return 'The selected CSV file is empty.';
    }
    return null;
  }
}
