import '../models/social_provider.dart';

abstract class OAuthStrategy {
  SocialProvider get provider;
  Future<Map<String, String?>> getTokens();
  String get clientId;
  Future<void> signOut();

  /// Apple only returns the user's name on the very first authorization, so
  /// providers that surface it expose it here for the repository to forward to
  /// the backend. Non-name providers (e.g. Google) leave these null.
  String? get lastGivenName => null;
  String? get lastFamilyName => null;

  /// Apple also returns the email only on the first authorization. Providers
  /// that surface it expose it here; others leave it null.
  String? get lastEmail => null;
}
