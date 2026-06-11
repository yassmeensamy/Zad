import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/services/upgrade_service.dart';
import 'upgrade_state.dart';

/// Drives the optional, non-blocking "update available" prompt surfaced on the
/// home shell. The blocking force-update path is handled earlier at startup by
/// `AppStartupCubit`; this cubit only covers the dismissible prompt.
class UpgradeCubit extends BaseCubit<UpgradeState> {
  UpgradeCubit({required UpgradeService upgradeService})
    : _upgradeService = upgradeService,
      super(const UpgradeState());

  final UpgradeService _upgradeService;

  /// One-shot check: re-entrant calls are ignored and the prompt is never
  /// re-surfaced once the check has resolved for this cubit's lifetime.
  Future<void> checkForUpdate({required String languageCode}) async {
    if (state.status != UpgradeStatus.initial) return;
    emit(state.copyWith(status: UpgradeStatus.checking));

    final available = await _upgradeService.isUpdateAvailable(
      languageCode: languageCode,
    );

    emit(
      available
          ? state.copyWith(
              status: UpgradeStatus.available,
              info: _upgradeService.info,
            )
          : state.copyWith(status: UpgradeStatus.unavailable),
    );
  }

  Future<void> openStore() => _upgradeService.openStore();
}
