import 'avatar_model.dart';

/// In-progress child profile assembled in the create-profiles form. The
/// avatar is fetched from the remote `/api/avatars` endpoint and stays null
/// until the parent picks one for this child.
class ChildDraft {
  const ChildDraft({
    required this.id,
    this.name = '',
    this.age = '',
    this.password = '',
    this.avatar,
  });

  final String id;
  final String name;
  final String age;
  final String password;
  final AvatarModel? avatar;

  bool get hasPassword => password.isNotEmpty;

  /// Best-effort birthDate inferred from the [age] field. Returns null
  /// when the age string isn't a positive integer.
  DateTime? get inferredBirthDate {
    final years = int.tryParse(age.trim());
    if (years == null || years <= 0) return null;
    final now = DateTime.now();
    return DateTime(now.year - years, now.month, now.day);
  }

  ChildDraft copyWith({
    String? name,
    String? age,
    String? password,
    AvatarModel? avatar,
  }) => ChildDraft(
    id: id,
    name: name ?? this.name,
    age: age ?? this.age,
    password: password ?? this.password,
    avatar: avatar ?? this.avatar,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildDraft &&
        other.id == id &&
        other.name == name &&
        other.age == age &&
        other.password == password &&
        other.avatar == avatar;
  }

  @override
  int get hashCode => Object.hash(id, name, age, password, avatar);
}
