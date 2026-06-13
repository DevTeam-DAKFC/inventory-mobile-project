import '../../core/errors/app_error_code.dart';
import '../../domain/models/inventory_movement.dart';
import '../../domain/models/stock_lookup.dart';

final class MovementFormState {
  const MovementFormState({
    this.productId,
    this.branchId,
    this.type = MovementType.incoming,
    this.quantity,
    this.reason = '',
    this.notes,
    this.currentStock,
    this.createdMovement,
    this.isSubmitting = false,
    this.isLoadingStock = false,
    this.fieldErrors = const {},
    this.errorCode,
    this.errorMessage,
    this.successMessage,
  });

  final String? productId;
  final String? branchId;
  final MovementType type;
  final int? quantity;
  final String reason;
  final String? notes;
  final StockLookup? currentStock;
  final InventoryMovement? createdMovement;
  final bool isSubmitting;
  final bool isLoadingStock;
  final Map<String, String> fieldErrors;
  final AppErrorCode? errorCode;
  final String? errorMessage;
  final String? successMessage;

  bool get canSubmit => !isSubmitting && !isLoadingStock;

  MovementFormState copyWith({
    String? productId,
    String? branchId,
    MovementType? type,
    int? quantity,
    String? reason,
    String? notes,
    StockLookup? currentStock,
    InventoryMovement? createdMovement,
    bool? isSubmitting,
    bool? isLoadingStock,
    Map<String, String>? fieldErrors,
    AppErrorCode? errorCode,
    String? errorMessage,
    String? successMessage,
    bool clearProductId = false,
    bool clearBranchId = false,
    bool clearQuantity = false,
    bool clearNotes = false,
    bool clearCurrentStock = false,
    bool clearCreatedMovement = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return MovementFormState(
      productId: clearProductId ? null : productId ?? this.productId,
      branchId: clearBranchId ? null : branchId ?? this.branchId,
      type: type ?? this.type,
      quantity: clearQuantity ? null : quantity ?? this.quantity,
      reason: reason ?? this.reason,
      notes: clearNotes ? null : notes ?? this.notes,
      currentStock: clearCurrentStock
          ? null
          : currentStock ?? this.currentStock,
      createdMovement: clearCreatedMovement
          ? null
          : createdMovement ?? this.createdMovement,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingStock: isLoadingStock ?? this.isLoadingStock,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
