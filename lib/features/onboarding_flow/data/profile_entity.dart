import '../../child/models/child_model.dart';
import 'child_avatar.dart';

/// View-layer entity that drives [ProfileCard]. The card is rendered for
/// three flavors: the signed-in parent, a real child (mapped from
/// [ChildModel]), or a skeleton placeholder for the loading state.
class ProfileEntity {
  const ProfileEntity.parent({required this.name})
      : isParent = true,
        childId = null,
        avatar = null,
        age = null,
        progress = null,
        streak = null,
        isPlaceholder = false;

  const ProfileEntity._child({
    required this.childId,
    required this.name,
    required this.age,
    required this.avatar,
  })  : isParent = false,
        progress = null,
        streak = null,
        isPlaceholder = false;

  const ProfileEntity.placeholder({
    required this.name,
    this.isParent = false,
  })  : childId = null,
        avatar = ChildAvatar.palm,
        age = 7,
        progress = 0.5,
        streak = 5,
        isPlaceholder = true;

  /// Maps a server-side [ChildModel] into a presentation [ProfileEntity].
  /// The avatar is selected by the caller (e.g. cycled from the enum) so
  /// the entity stays decoupled from any avatar-picking strategy.
  factory ProfileEntity.fromChildModel(
    ChildModel model, {
    required ChildAvatar avatar,
  }) =>
      ProfileEntity._child(
        childId: model.id,
        name: model.fullName,
        age: model.age,
        avatar: avatar,
      );

  /// Server id when the entity was mapped from a [ChildModel]; null for the
  /// parent and placeholder variants.
  final String? childId;
  final bool isParent;
  final String name;
  final int? age;
  final ChildAvatar? avatar;
  final double? progress;
  final int? streak;
  final bool isPlaceholder;
}
