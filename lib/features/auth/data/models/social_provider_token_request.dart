import 'dart:convert';

enum SocialProcess { login, connect }

extension SocialProcessX on SocialProcess {
  String get value {
    switch (this) {
      case SocialProcess.login:
        return 'login';
      case SocialProcess.connect:
        return 'connect';
    }
  }
}

class SocialProviderTokenRequest {
  final String provider;
  final SocialProcess process;
  final ProviderTokenModel token;

  const SocialProviderTokenRequest({
    required this.provider,
    required this.process,
    required this.token,
  });

  Map<String, dynamic> toMap() => {
    'provider': provider,
    'process': process.value,
    'token': token.toMap(),
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'SocialProviderTokenRequest(provider: $provider, process: ${process.value}, token: $token, )';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocialProviderTokenRequest &&
          other.provider == provider &&
          other.process == process &&
          other.token == token);

  @override
  int get hashCode => provider.hashCode ^ process.hashCode ^ token.hashCode;
}

class ProviderTokenModel {
  final String clientId;
  final String? idToken;
  final String? accessToken;

  const ProviderTokenModel({
    required this.clientId,
    this.idToken,
    this.accessToken,
  });

  Map<String, dynamic> toMap() => {
    'client_id': clientId,
    if (idToken != null) 'id_token': idToken,
    if (accessToken != null) 'access_token': accessToken,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ProviderTokenModel(clientId: $clientId, idToken: ${idToken != null ? '[PRESENT]' : null}, accessToken: ${accessToken != null ? '[PRESENT]' : null})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderTokenModel &&
          other.clientId == clientId &&
          other.idToken == idToken &&
          other.accessToken == accessToken);

  @override
  int get hashCode =>
      clientId.hashCode ^ idToken.hashCode ^ accessToken.hashCode;
}
