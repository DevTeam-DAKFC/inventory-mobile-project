import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error_code.dart';
import '../../core/validation/movement_validators.dart';
import '../../data/providers/inventory_movement_providers.dart';
import '../../domain/models/inventory_movement.dart';
import '../../domain/models/inventory_movement_create_request.dart';
import '../../domain/models/stock_lookup.dart';
import 'movement_form_state.dart';
import 'movement_providers.dart';

final movementFormViewModelProvider =
    NotifierProvider<MovementFormViewModel, MovementFormState>(
      MovementFormViewModel.new,
    );

class MovementFormViewModel extends Notifier<MovementFormState> {
  static const productField = 'productId';
  static const branchField = 'branchId';
  static const quantityField = 'quantity';
  static const reasonField = 'reason';

  @override
  MovementFormState build() => const MovementFormState();

  void setProductId(String? value) {
    state = state.copyWith(
      productId: value,
      clearCurrentStock: true,
      clearError: true,
      clearSuccess: true,
      fieldErrors: _withoutField(productField),
    );
  }

  void setBranchId(String? value) {
    state = state.copyWith(
      branchId: value,
      clearCurrentStock: true,
      clearError: true,
      clearSuccess: true,
      fieldErrors: _withoutField(branchField),
    );
  }

  void setType(MovementType value) {
    state = state.copyWith(type: value, clearError: true, clearSuccess: true);
  }

  void setQuantity(int? value) {
    state = state.copyWith(
      quantity: value,
      clearError: true,
      clearSuccess: true,
      fieldErrors: _withoutField(quantityField),
    );
  }

  void setReason(String value) {
    state = state.copyWith(
      reason: value,
      clearError: true,
      clearSuccess: true,
      fieldErrors: _withoutField(reasonField),
    );
  }

  void setNotes(String? value) {
    state = state.copyWith(notes: value, clearError: true, clearSuccess: true);
  }

  Future<void> loadCurrentStock() async {
    final productId = state.productId;
    final branchId = state.branchId;
    if (productId == null || branchId == null) return;

    state = state.copyWith(isLoadingStock: true, clearError: true);
    final result = await ref
        .read(stockLookupRepositoryProvider)
        .getStockLookup(productId: productId, branchId: branchId);

    result.when(
      success: (stock) {
        state = state.copyWith(currentStock: stock, isLoadingStock: false);
      },
      failure: (exception) {
        state = state.copyWith(
          isLoadingStock: false,
          errorCode: exception.code,
          errorMessage: exception.message,
        );
      },
    );
  }

  Future<void> submit() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: errors,
        errorCode: AppErrorCode.validationError,
        errorMessage: 'Please review the movement form fields.',
        clearSuccess: true,
      );
      return;
    }

    final productId = state.productId!;
    final branchId = state.branchId!;
    state = state.copyWith(
      isSubmitting: true,
      fieldErrors: const {},
      clearError: true,
      clearSuccess: true,
      clearCreatedMovement: true,
    );

    final result = await ref
        .read(inventoryMovementRepositoryProvider)
        .createMovement(
          InventoryMovementCreateRequest(
            productId: productId,
            branchId: branchId,
            type: state.type,
            quantity: state.quantity!,
            reason: state.reason.trim(),
            notes: _emptyToNull(state.notes),
          ),
        );

    await result.when(
      success: (movement) async {
        final refreshedStock = await _refreshStock(productId, branchId);
        ref.invalidate(movementHistoryProvider);
        state = state.copyWith(
          isSubmitting: false,
          currentStock: refreshedStock,
          createdMovement: movement,
          successMessage: 'Movement registered successfully.',
        );
      },
      failure: (exception) async {
        state = state.copyWith(
          isSubmitting: false,
          errorCode: exception.code,
          errorMessage: exception.code == AppErrorCode.insufficientStock
              ? 'Not enough stock available to register this movement.'
              : exception.message,
        );
      },
    );
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};

    final productError = MovementValidators.validateProductId(state.productId);
    if (productError != null) errors[productField] = productError;

    final branchError = MovementValidators.validateBranchId(state.branchId);
    if (branchError != null) errors[branchField] = branchError;

    final quantityError = MovementValidators.validateQuantity(state.quantity);
    if (quantityError != null) errors[quantityField] = quantityError;

    final reasonError = MovementValidators.validateReason(state.reason);
    if (reasonError != null) errors[reasonField] = reasonError;

    return errors;
  }

  Future<StockLookup?> _refreshStock(String productId, String branchId) async {
    final result = await ref
        .read(stockLookupRepositoryProvider)
        .getStockLookup(productId: productId, branchId: branchId);
    return result.dataOrNull;
  }

  Map<String, String> _withoutField(String field) {
    return Map<String, String>.from(state.fieldErrors)..remove(field);
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
