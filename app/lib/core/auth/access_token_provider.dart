/// Provides an access token for authenticated backend requests.
///
/// The real implementation should be connected by the authentication module.
/// Until then, [DevAccessTokenProvider] keeps development tokens isolated from
/// UI and feature code.
abstract class AccessTokenProvider {
  Future<String?> getAccessToken();
}

final class DevAccessTokenProvider implements AccessTokenProvider {
  const DevAccessTokenProvider({String? token}) : _token = token ?? _envToken;

  static const String _envToken = String.fromEnvironment('DEV_ACCESS_TOKEN');

  final String _token;

  @override
  Future<String?> getAccessToken() async {
    final trimmed = _token.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
