class UpgradeInfo {
  const UpgradeInfo({
    this.installedVersion,
    this.availableVersion,
    this.releaseNotes,
  });

  final String? installedVersion;
  final String? availableVersion;
  final String? releaseNotes;

  static const UpgradeInfo empty = UpgradeInfo();

  static const UpgradeInfo mock = UpgradeInfo(
    installedVersion: '1.0.0',
    availableVersion: '2.0.0',
    releaseNotes:
        'What\'s new in this test build:\n• Faster quizzes\n• Bug fixes and polish',
  );
}
