import '../models/social_provider.dart';
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

  OAuthStrategy getStrategy(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return _googleStrategy;
    }
  }
}

class OAuthConfig {
  const OAuthConfig({
    required this.googleAndroidClientId,
    required this.googleIosClientId,
    required this.googleServerClientId,
  });

  final String googleAndroidClientId;
  final String googleIosClientId;
  final String googleServerClientId;
}
