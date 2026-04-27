import '../models/social_provider.dart';

abstract class OAuthStrategy {
  SocialProvider get provider;
  Future<Map<String, String?>> getTokens();
  String get clientId;
  Future<void> signOut();
}
