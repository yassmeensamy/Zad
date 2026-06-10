/// The user's chosen answer for one question, captured at submission time and
/// threaded from `QuizState.history` into the offline persistence path so the
/// stored record carries the actual selected choice (not just correctness).
class PendingAnswerInput {
  const PendingAnswerInput({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  final int questionId;

  /// The chosen choice index (`ChoiceModel.index`). `-1` if unknown.
  final int selectedAnswer;
  final bool isCorrect;
}
