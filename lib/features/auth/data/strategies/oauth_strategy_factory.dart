import '../models/social_provider.dart';
import 'apple_oauth_strategy.dart';
import 'google_oauth_strategy.dart';
import 'oauth_strategy.dart';

class OAuthStrategyFactory {
  OAuthStrategyFactory({required OAuthConfig config}) : _config = config;

  final OAuthConfig _config;

  late final GoogleOAuthStrategy _googleStrategy = GoogleOAuthStrategy(
    androidClientId: _config.googleAndroidClientId,
    iosClientId: _config.googleIosClientId,
    serverClientId: _config.googleServerClientId,
  );

  late final AppleOAuthStrategy _appleStrategy = AppleOAuthStrategy(
    appleServiceId: _config.appleServiceId,
    redirectUri: _config.appleRedirectUri,
  );

  OAuthStrategy getStrategy(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return _googleStrategy;
      case SocialProvider.apple:
        return _appleStrategy;
    }
  }
}

class OAuthConfig {
  const OAuthConfig({
    required this.googleAndroidClientId,
    required this.googleIosClientId,
    required this.googleServerClientId,
    this.appleServiceId = '',
    this.appleRedirectUri,
  });

  final String googleAndroidClientId;
  final String googleIosClientId;
  final String googleServerClientId;

  /// Apple Services ID + return URL — only needed for the Android/web flow.
  /// Safe to leave at defaults for an iOS-only Apple sign-in.
  final String appleServiceId;
  final String? appleRedirectUri;
}
