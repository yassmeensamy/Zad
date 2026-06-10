import 'dart:async';

import '../../../core/api/network_failure.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/logger.dart';
import '../../auth/core/auth_event_service.dart';
import '../../auth/core/auth_status.dart';
import '../../quiz/core/quiz_event_service.dart';
import '../../quiz/data/models/quiz_submission_request.dart';
import '../../quiz/data/models/quiz_sync_request.dart';
import '../../quiz/data/remote/quiz_remote_data_source.dart';
import '../data/local/pending_answers_dao.dart';

/// Flushes offline-saved answers to the backend. The whole pending queue is
/// replayed in a single `POST /api/quiz/sync` batch call. Runs once at
/// startup-after-auth, again whenever connectivity is regained, and on a fresh
/// login.
class OfflineSyncService {
  OfflineSyncService({
    required PendingAnswersDao pendingDao,
    required QuizRemoteDataSource quizRemote,
    required QuizEventService quizEventService,
    required ConnectivityService connectivityService,
    required AuthEventService authEventService,
  }) : _pendingDao = pendingDao,
       _quizRemote = quizRemote,
       _events = quizEventService,
       _connectivity = connectivityService,
       _auth = authEventService;

  final PendingAnswersDao _pendingDao;
  final QuizRemoteDataSource _quizRemote;
  final QuizEventService _events;
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
      final attempts = await _pendingDao.getUnsyncedGroupedByAttempt();
      if (attempts.isNotEmpty) {
        final request = QuizSyncRequest(
          submissions: [
            for (final attempt in attempts)
              QuizLevelSubmission(
                levelId: attempt.levelId,
                pointsEarned: attempt.pointsEarned,
                answers: [
                  for (final row in attempt.rows)
                    QuizAnswerSubmission(
                      questionId: row.questionId,
                      isCorrect: row.isCorrect,
                    ),
                ],
              ),
          ],
        );
        try {
          await _quizRemote.syncQuiz(request);
          for (final attempt in attempts) {
            await _pendingDao.markAttemptSynced(attempt.attemptId);
            _events.notifySubmitted(attempt.levelId);
          }
        } catch (e) {
          if (!isConnectivityError(e)) {
            // Server rejected the batch (not a connectivity drop). Mark every
            // attempt synced so a poison payload never blocks the queue forever.
            logger.error('OfflineSync: dropping rejected batch: $e');
            for (final attempt in attempts) {
              await _pendingDao.markAttemptSynced(attempt.attemptId);
            }
          }
          // Connectivity error: leave the queue intact, retry on next trigger.
        }
      }
      await _pendingDao.deleteSyncedOlderThan(const Duration(days: 7));
    } catch (e) {
      logger.error('OfflineSync.sync failed: $e');
    } finally {
      _syncing = false;
    }
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _authSub?.cancel();
  }
}
