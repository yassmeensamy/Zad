/// View-model for one podium pedestal or ranking row.
///
/// Decouples the leaderboard widgets from whether the underlying entry is an
/// individual or a team, and centralises the completion-percentage maths so the
/// podium, the list rows and the body all read from one shape.
class RankSeed {
  const RankSeed({
    required this.rank,
    required this.name,
    required this.completed,
    required this.total,
    this.subtitle,
    this.isMe = false,
  });

  final int rank;
  final String name;
  final int completed;
  final int total;
  final String? subtitle;
  final bool isMe;

  int get percent =>
      total <= 0 ? 0 : ((completed / total).clamp(0, 1) * 100).round();
}
