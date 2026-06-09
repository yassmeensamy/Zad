/// Central definition of the app's web deep links (Universal Links on iOS /
/// App Links on Android).
///
/// Everything about the link format lives here so the host and path never get
/// hardcoded in multiple places. If the domain changes, change [host] only —
/// then update the matching values in:
///   • android/app/src/main/AndroidManifest.xml  (intent-filter android:host)
///   • ios/Runner/Runner.entitlements             (`applinks:` + host)
///   • the hosted association files (.well-known/assetlinks.json and
///     .well-known/apple-app-site-association)
class DeepLinks {
  const DeepLinks._();

  /// The verified domain that serves the association files. Must be a domain
  /// you control and can upload `/.well-known/` files to.
  static const String host = 'zaad-7a0a8.web.app';

  /// Path of the team-join deep link. Matches the existing in-app route so
  /// go_router navigates there automatically when the OS delivers the link.
  static const String teamJoinPath = '/teams/join';

  /// Query key carrying the 8-char invite code.
  static const String codeParam = 'code';

  /// Custom URL scheme used only to *open* the app (never shared directly).
  /// The fallback web page launches `zad://teams/join?code=...` to reach the
  /// app without relying on domain verification.
  static const String scheme = 'zad';

  /// Builds the shareable invite URL, e.g.
  /// `https://zaad-7a0a8.web.app/teams/join?code=ABC12345`.
  static String teamInvite(String code) =>
      Uri.https(host, teamJoinPath, {codeParam: code}).toString();

  /// Maps an incoming deep-link [uri] to a go_router location string, or `null`
  /// if the link isn't one of ours.
  ///
  /// Two shapes are accepted:
  /// * `https://<host>/teams/join?code=...` — App/Universal Link. The path is
  ///   already correct; we keep path + query.
  /// * `zad://teams/join?code=...` — custom scheme. Because the URI has a
  ///   scheme, its first segment (`teams`) is parsed as the *host*, leaving
  ///   [Uri.path] as just `/join`; we rebuild the full path (`/teams/join`).
  static String? toLocation(Uri uri) {
    if (uri.scheme == scheme) {
      final segments = [
        uri.host,
        ...uri.pathSegments,
      ].where((s) => s.isNotEmpty).toList();
      return Uri(
        path: '/${segments.join('/')}',
        queryParameters:
            uri.queryParameters.isEmpty ? null : uri.queryParameters,
      ).toString();
    }
    if (uri.scheme == 'https' && uri.host == host) {
      return Uri(
        path: uri.path,
        queryParameters:
            uri.queryParameters.isEmpty ? null : uri.queryParameters,
      ).toString();
    }
    return null;
  }
}
