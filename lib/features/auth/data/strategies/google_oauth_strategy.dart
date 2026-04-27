// TODO: requires `google_sign_in` package — add to pubspec.yaml dependencies.
import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

import '../models/social_provider.dart';
import 'oauth_strategy.dart';

const _googleScopes = ['email', 'profile', 'openid'];

class GoogleOAuthStrategy implements OAuthStrategy {
  GoogleOAuthStrategy({
    required String androidClientId,
    required String iosClientId,
    required String serverClientId,
  }) : _androidClientId = androidClientId,
       _iosClientId = iosClientId,
       _serverClientId = serverClientId;

  final String _androidClientId;
  final String _iosClientId;
  final String _serverClientId;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Completer<void>? _initCompleter;

  @override
  SocialProvider get provider => SocialProvider.google;

  @override
  String get clientId => _serverClientId;

  @override
  Future<Map<String, String?>> getTokens() async {
    try {
      await _ensureInitialized();
      final account = await _authenticateWithGoogle();
      final tokens = await _extractTokensFromAccount(account);
      _validateTokens(tokens);
      return tokens;
    } on GoogleSignInException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      await _googleSignIn.signOut();
    }
  }

  Future<GoogleSignInAccount> _authenticateWithGoogle() async {
    return await _googleSignIn.authenticate();
  }

  Future<Map<String, String?>> _extractTokensFromAccount(
    GoogleSignInAccount account,
  ) async {
    final authorization = await account.authorizationClient
        .authorizationForScopes(_googleScopes);
    final authentication = account.authentication;

    return {
      'accessToken': authorization?.accessToken,
      'idToken': authentication.idToken,
    };
  }

  void _validateTokens(Map<String, String?> tokens) {
    final hasAccessToken = tokens['accessToken'] != null;
    final hasIdToken = tokens['idToken'] != null;

    if (!hasAccessToken && !hasIdToken) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description:
            'Failed to retrieve tokens. Both access token and ID token are null.',
      );
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();
    try {
      await _googleSignIn.initialize(
        clientId: Platform.isAndroid ? _androidClientId : _iosClientId,
        serverClientId: _serverClientId,
      );
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter = null;
      rethrow;
    }
  }
}
