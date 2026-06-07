import '../constants/api_config.dart';

/// Resolves backend-managed relative asset paths for future presentation.
final class PublicAssetUrlResolver {
  const PublicAssetUrlResolver(this._config);

  final ApiConfig _config;

  String? resolve(String? assetUrl) {
    if (assetUrl == null) return null;

    final uri = Uri.tryParse(assetUrl);
    if (uri != null && uri.hasScheme) return assetUrl;

    final base = _config.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final path = assetUrl.replaceFirst(RegExp(r'^/+'), '');
    return '$base/$path';
  }
}
