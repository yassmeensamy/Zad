import 'dart:async';

import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/services/connectivity_service.dart';

/// Exposes the online/offline state to the UI (drives the offline banner).
/// State is `true` when online.
class ConnectivityCubit extends BaseCubit<bool> {
  ConnectivityCubit(this._service) : super(_service.isOnline) {
    _subscription = _service.onStatusChanged.listen(emit);
  }

  final ConnectivityService _service;
  late final StreamSubscription<bool> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
