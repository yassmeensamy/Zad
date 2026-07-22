import '../../../../core/cubits/base_cubit.dart';
import 'quiz_history_state.dart';

class QuizHistoryCubit extends BaseCubit<QuizHistoryState> {
  QuizHistoryCubit() : super(const QuizHistoryState());

  void back({required int historyLength, required bool liveIsAnswered}) {
    final i = state.viewingIndex;
    if (i != null) {
      if (i > 0) emit(QuizHistoryState(viewingIndex: i - 1));
      return;
    }
    final target = liveIsAnswered ? historyLength - 2 : historyLength - 1;
    if (target >= 0) emit(QuizHistoryState(viewingIndex: target));
  }

  void forward(int historyLength) {
    final i = state.viewingIndex;
    if (i == null) return;
    if (i < historyLength - 1) {
      emit(QuizHistoryState(viewingIndex: i + 1));
    } else {
      exit();
    }
  }

  void exit() => emit(const QuizHistoryState());
}
