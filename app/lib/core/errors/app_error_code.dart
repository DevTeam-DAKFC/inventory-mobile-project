/// Machine-readable error vocabulary shared between repositories, data
/// sources and the OpenAPI contract documented in
/// `docs/api-contracts/openapi.inventory-api.yaml`.
enum AppErrorCode {
  validationError('validation_error'),
  unauthorized('unauthorized'),
  forbidden('forbidden'),
  notFound('not_found'),
  conflict('conflict'),
  insufficientStock('insufficient_stock'),
  inactiveProduct('inactive_product'),
  inactiveBranch('inactive_branch'),
  productNotFound('product_not_found'),
  serviceUnavailable('service_unavailable'),
  uploadSessionExpired('upload_session_expired'),
  uploadNotCompleted('upload_not_completed'),
  networkError('network_error'),
  timeout('timeout'),
  unexpected('unexpected');

  const AppErrorCode(this.value);

  /// API-style snake_case representation of this error code.
  final String value;
}
