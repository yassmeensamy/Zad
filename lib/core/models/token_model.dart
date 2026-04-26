import 'dart:convert';

class TokensModel {
  TokensModel({required this.access, required this.refresh});

  factory TokensModel.fromMap(Map<String, dynamic> map) =>
      TokensModel(access: map['access'], refresh: map['refresh']);

  factory TokensModel.fromJson(String source) =>
      TokensModel.fromMap(json.decode(source));
  final String access;
  final String refresh;
  TokensModel copyWith({String? access, String? refresh}) => TokensModel(
    access: access ?? this.access,
    refresh: refresh ?? this.refresh,
  );

  Map<String, dynamic> toMap() => {'access': access, 'refresh': refresh};

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
