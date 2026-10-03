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
}
