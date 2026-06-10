import '../constants/storage_keys.dart';
import '../models/user_model.dart';
import 'cache_service.dart';

/// Resolves the logged-in user's id for namespacing offline rows so a download
/// (or pending answer) made by one account never surfaces under another on a
/// shared device. Reads the cached profile written by `UserRepository`.
///
/// The id is memoised after the first read; [clear] is called on logout so the
/// next account resolves fresh.
class CurrentUserProvider {
  CurrentUserProvider(this._cacheService);

  final CacheService _cacheService;
  String? _cached;

  /// Falls back to [anonymous] when no profile is cached yet (e.g. guest before
  /// `/me` resolves) so writes still have a stable, isolated namespace.
  static const String anonymous = 'anonymous';

  Future<String> userId() async {
    final cached = _cached;
    if (cached != null) return cached;
    final raw = await _cacheService.get<String>(StorageKeys.kUserKey);
    if (raw == null || raw.isEmpty) return anonymous;
    try {
      final id = UserModel.fromJson(raw).id;
      _cached = id;
      return id;
    } catch (_) {
      return anonymous;
    }
  }

  void clear() => _cached = null;
}
