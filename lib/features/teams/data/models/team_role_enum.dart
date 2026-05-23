enum TeamRoleEnum {
  owner(apiValue: 'OWNER'),
  member(apiValue: 'MEMBER');

  const TeamRoleEnum({required this.apiValue});

  final String apiValue;

  String toApi() => apiValue;

  static TeamRoleEnum fromApi(String? value) =>
      TeamRoleEnum.values.firstWhere(
        (e) => e.apiValue == value,
        orElse: () => TeamRoleEnum.member,
      );
}
