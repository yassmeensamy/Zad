import '../../../../core/services/upgrade_info.dart';

enum UpgradeStatus { initial, checking, available, unavailable }

class UpgradeState {
  const UpgradeState({
    this.status = UpgradeStatus.initial,
    this.info = UpgradeInfo.empty,
  });

  final UpgradeStatus status;
  final UpgradeInfo info;

  UpgradeState copyWith({
    UpgradeStatus? status,
    UpgradeInfo? info,
  }) => UpgradeState(
    status: status ?? this.status,
    info: info ?? this.info,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpgradeState &&
        other.status == status &&
        other.info == info;
  }

  @override
  int get hashCode => Object.hash(status, info);
}

extension UpgradeStateX on UpgradeState {
  bool get isChecking => status == UpgradeStatus.checking;
  bool get isUpdateAvailable => status == UpgradeStatus.available;
}
