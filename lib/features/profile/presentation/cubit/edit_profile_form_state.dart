import '../../../../core/models/user_model.dart';

class EditProfileFormState {
  const EditProfileFormState({this.updatedUser});

  final UserModel? updatedUser;

  /// Dirty is derived against [savedUser] (the source of truth in UserCubit).
  bool isDirtyAgainst(UserModel? savedUser) {
    final edited = updatedUser;
    if (savedUser == null || edited == null) return false;
    return savedUser.fullName.trim() != edited.fullName.trim() ||
        savedUser.birthDate != edited.birthDate;
  }

  EditProfileFormState copyWith({UserModel? updatedUser}) =>
      EditProfileFormState(updatedUser: updatedUser ?? this.updatedUser);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditProfileFormState && other.updatedUser == updatedUser;

  @override
  int get hashCode => updatedUser.hashCode;
}
