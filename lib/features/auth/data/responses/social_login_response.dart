import 'log_in_response.dart';

class SocialLoginResponse extends LogInResponse {
  final SocialLoginData? data;

  const SocialLoginResponse({
    required super.sessionToken,
    required super.isActive,
    this.data,
  });

  factory SocialLoginResponse.fromMap(Map<String, dynamic> map) =>
      SocialLoginResponse(
        sessionToken: map['meta']['session_token'] as String,
        isActive: map['meta']['is_active'] as bool,
        data: map['data'] != null
            ? SocialLoginData.fromMap(map['data'] as Map<String, dynamic>)
            : null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialLoginResponse &&
        other.sessionToken == sessionToken &&
        other.isActive == isActive &&
        other.data == data;
  }

  @override
  int get hashCode => sessionToken.hashCode ^ isActive.hashCode ^ data.hashCode;
}

class SocialLoginData {
  final UserModel user;

  const SocialLoginData({required this.user});

  factory SocialLoginData.fromMap(Map<String, dynamic> map) => SocialLoginData(
    user: UserModel.fromMap(map['user'] as Map<String, dynamic>),
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialLoginData && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

class UserModel {
  final int id;
  final String email;
  final String language;
  final dynamic customer;
  final dynamic doctor;
  final SocialProfile? socialProfile;

  const UserModel({
    required this.id,
    required this.email,
    required this.language,
    this.customer,
    this.doctor,
    this.socialProfile,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as int,
    email: map['email'] as String,
    language: map['language'] as String,
    customer: map['customer'],
    doctor: map['doctor'],
    socialProfile: map['social_profile'] != null
        ? SocialProfile.fromMap(map['social_profile'] as Map<String, dynamic>)
        : null,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.language == language &&
        other.customer == customer &&
        other.doctor == doctor &&
        other.socialProfile == socialProfile;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      language.hashCode ^
      customer.hashCode ^
      doctor.hashCode ^
      socialProfile.hashCode;
}

class SocialProfile {
  final String provider;
  final String? name;
  final String? givenName;
  final String? familyName;
  final String? picture;

  const SocialProfile({
    required this.provider,
    this.name,
    this.givenName,
    this.familyName,
    this.picture,
  });

  factory SocialProfile.fromMap(Map<String, dynamic> map) => SocialProfile(
    provider: map['provider'] as String,
    name: map['name'] as String?,
    givenName: map['given_name'] as String?,
    familyName: map['family_name'] as String?,
    picture: map['picture'] as String?,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialProfile &&
        other.provider == provider &&
        other.name == name &&
        other.givenName == givenName &&
        other.familyName == familyName &&
        other.picture == picture;
  }

  @override
  int get hashCode =>
      provider.hashCode ^
      name.hashCode ^
      givenName.hashCode ^
      familyName.hashCode ^
      picture.hashCode;
}

class SocialLoginResult {
  const SocialLoginResult({required this.response});

  final SocialLoginResponse response;
}
