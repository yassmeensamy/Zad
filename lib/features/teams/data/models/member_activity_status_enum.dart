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
}
