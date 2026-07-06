enum MemberActivityStatus {
  active,
  consistent,
  idle;

  static MemberActivityStatus fromApi(String? value) =>
      switch (value?.toLowerCase()) {
        'active' => MemberActivityStatus.active,
        'consistent' => MemberActivityStatus.consistent,
        'idle' => MemberActivityStatus.idle,
        _ => MemberActivityStatus.idle,
      };

  String toApi() => name;

  String get label => switch (this) {
        MemberActivityStatus.active => 'Active',
        MemberActivityStatus.consistent => 'Consistent',
        MemberActivityStatus.idle => 'Idle',
      };

  /// Translation key for the localized status label; resolve with `.tr()`.
  String get labelKey => switch (this) {
        MemberActivityStatus.active => 'teams.activity_status.active',
        MemberActivityStatus.consistent => 'teams.activity_status.consistent',
        MemberActivityStatus.idle => 'teams.activity_status.idle',
      };
}
