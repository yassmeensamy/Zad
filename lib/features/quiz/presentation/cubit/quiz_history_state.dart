class QuizHistoryState {
  const QuizHistoryState({this.viewingIndex});

  /// When non-null, the user is viewing a past entry from
  /// [QuizState.history] in read-only mode.
  final int? viewingIndex;

  bool get isViewing => viewingIndex != null;

  QuizHistoryState copyWith({int? Function()? viewingIndex}) =>
      QuizHistoryState(
        viewingIndex:
            viewingIndex != null ? viewingIndex() : this.viewingIndex,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizHistoryState && other.viewingIndex == viewingIndex;

  @override
  int get hashCode => viewingIndex.hashCode;
}
