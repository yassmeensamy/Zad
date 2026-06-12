import 'dart:async';

import '../../../core/api/network_failure.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/logger.dart';
import '../../auth/core/auth_event_service.dart';
import '../../auth/core/auth_status.dart';
import '../data/local/pending_drafts_dao.dart';
import '../data/models/draft_request.dart';
import '../data/remote/drafts_remote_data_source.dart';

/// Flushes drafts the user marked while offline to the backend. The whole
/// pending queue is replayed in a single `POST /api/drafts/bulk` batch. Runs
/// once at startup-after-auth, again whenever connectivity is regained, and on
/// a fresh login. Mirrors [OfflineSyncService] for quiz answers.
class DraftsSyncService {
  DraftsSyncService({
    required PendingDraftsDao pendingDao,
    required DraftsRemoteDataSource draftsRemote,
    required ConnectivityService connectivityService,
    required AuthEventService authEventService,
  })  : _pendingDao = pendingDao,
        _draftsRemote = draftsRemote,
        _connectivity = connectivityService,
        _auth = authEventService;

  final PendingDraftsDao _pendingDao;
  final DraftsRemoteDataSource _draftsRemote;
  final ConnectivityService _connectivity;
  final AuthEventService _auth;

  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<AuthEvent>? _authSub;
  bool _syncing = false;
  bool _started = false;

  /// Wires the triggers and performs an initial sync. Idempotent.
  Future<void> start() async {
    if (!_started) {
      _started = true;
      _connectivitySub = _connectivity.onStatusChanged.listen((online) {
        if (online) sync();
      });
      _authSub = _auth.onAuthEvent.listen((event) {
        if (event == AuthEvent.loggedIn) sync();
      });
    }
    await sync();
  }

  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final pending = await _pendingDao.getUnsynced();
      if (pending.isNotEmpty) {
        final requests = [
          for (final draft in pending)
            CreateDraftRequest(questionId: draft.questionId, note: draft.note),
        ];
        try {
          await _draftsRemote.createDraftsBulk(requests);
          for (final draft in pending) {
            await _pendingDao.markSynced(draft.localId);
          }
        } catch (e) {
          if (!isConnectivityError(e)) {
            // Server rejected the batch (not a connectivity drop). Mark every
            // row synced so a poison payload never blocks the queue forever.
            logger.error('DraftsSync: dropping rejected batch: $e');
            for (final draft in pending) {
              await _pendingDao.markSynced(draft.localId);
            }
          }
          // Connectivity error: leave the queue intact, retry on next trigger.
        }
      }
      await _pendingDao.deleteSyncedOlderThan(const Duration(days: 7));
    } catch (e) {
      logger.error('DraftsSync.sync failed: $e');
    } finally {
      _syncing = false;
    }
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _authSub?.cancel();
  }
}
