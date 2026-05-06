import '../../../../core/cubits/base_cubit.dart';
import 'quiz_history_state.dart';

/// Read-only navigation through previously-answered questions. Owns only
/// the viewing index — the underlying history list lives on [QuizCubit].
/// Callers provide the relevant quiz facts (history length, whether the
/// live question is already answered) so this cubit has no direct
/// dependency on [QuizCubit].
class QuizHistoryCubit extends BaseCubit<QuizHistoryState> {
  QuizHistoryCubit() : super(const QuizHistoryState());

  /// Step backward. From live view, jump to the most recent past entry
  /// (one before the current question if it's already answered, else the
  /// latest entry). Within history, decrement until the start.
  void back({required int historyLength, required bool liveIsAnswered}) {
    final i = state.viewingIndex;
    if (i != null) {
      if (i > 0) emit(QuizHistoryState(viewingIndex: i - 1));
      return;
    }
    final target = liveIsAnswered ? historyLength - 2 : historyLength - 1;
    if (target >= 0) emit(QuizHistoryState(viewingIndex: target));
  }

  /// Step forward through history. On the last entry, exit review and
  /// return to the live state.
  void forward(int historyLength) {
    final i = state.viewingIndex;
    if (i == null) return;
    if (i < historyLength - 1) {
      emit(QuizHistoryState(viewingIndex: i + 1));
    } else {
      exit();
    }
  }

  /// Drop the viewing index and return to live view. Called by the screen
  /// via a [BlocListener] when the quiz reloads (history empties).
  void exit() => emit(const QuizHistoryState());
}
