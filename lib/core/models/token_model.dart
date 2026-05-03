import 'dart:convert';

class TokensModel {
  TokensModel({required this.access, required this.refresh});

  factory TokensModel.fromMap(Map<String, dynamic> map) => TokensModel(
    access: (map['accessToken'] ?? map['access']) as String,
    refresh: (map['refreshToken'] ?? map['refresh']) as String,
  );

  factory TokensModel.fromJson(String source) =>
      TokensModel.fromMap(json.decode(source));
  final String access;
  final String refresh;
  TokensModel copyWith({String? access, String? refresh}) => TokensModel(
    access: access ?? this.access,
    refresh: refresh ?? this.refresh,
  );

  Map<String, dynamic> toMap() => {
    'accessToken': access,
    'refreshToken': refresh,
  };

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'TokensModel(access: $access, refresh: $refresh,)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TokensModel &&
        other.access == access &&
        other.refresh == refresh;
  }

  @override
  int get hashCode => access.hashCode ^ refresh.hashCode;
}
