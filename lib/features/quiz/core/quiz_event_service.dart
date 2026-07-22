import 'dart:async';

class QuizEventService {
  final _submittedController = StreamController<int>.broadcast();
  final _resetController = StreamController<void>.broadcast();

  Stream<int> get onSubmitted => _submittedController.stream;

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
