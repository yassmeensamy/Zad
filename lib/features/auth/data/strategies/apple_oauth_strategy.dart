import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/social_provider.dart';
import 'oauth_strategy.dart';

class AppleOAuthStrategy implements OAuthStrategy {
  AppleOAuthStrategy({required String appleServiceId, this.redirectUri})
    : _appleServiceId = appleServiceId;

  /// Apple "Services ID" — only needed for the web/Android auth flow. Native
  /// iOS sign-in ignores it and uses the app's bundle id instead.
  final String _appleServiceId;

  /// HTTPS return URL registered against the Services ID. Required to run the
  /// web fallback (Android); left null on iOS-only setups.
  final String? redirectUri;

  AuthorizationCredentialAppleID? _lastCredential;

  @override
  SocialProvider get provider => SocialProvider.apple;

  @override
  String get clientId => _appleServiceId;

  @override
  String? get lastGivenName => _lastCredential?.givenName;

  @override
  String? get lastFamilyName => _lastCredential?.familyName;

  @override
  String? get lastEmail => _lastCredential?.email;

  @override
  Future<Map<String, String?>> getTokens() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: _webAuthenticationOptions,
    );
    _lastCredential = credential;
    return {
      'idToken': credential.identityToken,
      'accessToken': credential.authorizationCode,
    };
  }

  /// Only supplied when a Services ID + redirect URI are configured (needed for
  /// the Android/web flow). iOS resolves these natively, so we pass null there.
  WebAuthenticationOptions? get _webAuthenticationOptions {
    final uri = redirectUri;
    if (_appleServiceId.isEmpty || uri == null || uri.isEmpty) return null;
    return WebAuthenticationOptions(
      clientId: _appleServiceId,
      redirectUri: Uri.parse(uri),
    );
  }

  @override
  Future<void> signOut() async {
    _lastCredential = null;
  }
}
