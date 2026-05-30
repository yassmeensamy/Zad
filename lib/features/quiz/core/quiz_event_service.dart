import 'dart:async';

/// Cross-feature event bus for quiz lifecycle signals. Lives as a
/// singleton in the service locator so cubits in unrelated route trees
/// can communicate without holding direct references to one another.
class QuizEventService {
  final _submittedController = StreamController<int>.broadcast();
  final _resetController = StreamController<void>.broadcast();

  /// Fires after [QuizCubit.submit] succeeds. The payload is the
  /// completed level id. Listeners — typically [LevelsCubit] — can use it
  /// to refresh dependent screens.
  Stream<int> get onSubmitted => _submittedController.stream;

  /// Fires after the user's progress is reset (whole account, a single
  /// category, or a single level). Listeners — [CategoriesCubit] and
  /// [LevelsCubit] — use it to refresh the lists they currently display.
  Stream<void> get onReset => _resetController.stream;

  void notifySubmitted(int levelId) {
    if (!_submittedController.isClosed) {
      _submittedController.add(levelId);
    }
  }

  void notifyReset() {
    if (!_resetController.isClosed) {
      _resetController.add(null);
    }
  }

  void dispose() {
    _submittedController.close();
    _resetController.close();
  }
}
