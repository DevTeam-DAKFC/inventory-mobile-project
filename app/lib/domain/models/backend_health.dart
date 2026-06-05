/// Reported health state of the inventory backend.
///
/// Mirrors the minimal payload exposed by `GET /health` on the ASP.NET Core
/// Web API in the separate `inventory-backend` repository.
final class BackendHealth {
  const BackendHealth({required this.status, required this.service});

  final String status;
  final String service;

  bool get isOk => status.toLowerCase() == 'ok';
}
