import '../../../../core/models/user_model.dart';

enum UserStatus { initial, loading, success, error }

enum UpdateProfileStatus { initial, loading, success, error }

enum ChangePasswordStatus { initial, loading, success, error }

extension UserStatusX on UserState {
  bool get isInitial => status == UserStatus.initial;
  bool get isLoading => status == UserStatus.loading;
  bool get isSuccess => status == UserStatus.success;
  bool get isError => status == UserStatus.error;

  bool get isUpdateLoading => updateStatus == UpdateProfileStatus.loading;
  bool get isUpdateSuccess => updateStatus == UpdateProfileStatus.success;
  bool get isUpdateError => updateStatus == UpdateProfileStatus.error;

  bool get isPasswordLoading =>
      changePasswordStatus == ChangePasswordStatus.loading;
  bool get isPasswordSuccess =>
      changePasswordStatus == ChangePasswordStatus.success;
  bool get isPasswordError =>
      changePasswordStatus == ChangePasswordStatus.error;
}

class UserState {
  const UserState({
    this.status = UserStatus.initial,
    this.updateStatus = UpdateProfileStatus.initial,
    this.changePasswordStatus = ChangePasswordStatus.initial,
    this.user,
    this.errorMessage,
    this.updateErrorMessage,
    this.changePasswordErrorMessage,
  });

  final UserStatus status;
  final UpdateProfileStatus updateStatus;
  final ChangePasswordStatus changePasswordStatus;
  final UserModel? user;
  final String? errorMessage;
  final String? updateErrorMessage;
  final String? changePasswordErrorMessage;

  UserState copyWith({
    UserStatus? status,
    UpdateProfileStatus? updateStatus,
    ChangePasswordStatus? changePasswordStatus,
    UserModel? user,
    String? errorMessage,
    String? updateErrorMessage,
    String? changePasswordErrorMessage,
  }) => UserState(
    status: status ?? this.status,
    updateStatus: updateStatus ?? this.updateStatus,
    changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
    user: user ?? this.user,
    errorMessage: errorMessage,
    updateErrorMessage: updateErrorMessage,
    changePasswordErrorMessage: changePasswordErrorMessage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserState &&
          other.status == status &&
          other.updateStatus == updateStatus &&
          other.changePasswordStatus == changePasswordStatus &&
          other.user == user &&
          other.errorMessage == errorMessage &&
          other.updateErrorMessage == updateErrorMessage &&
          other.changePasswordErrorMessage == changePasswordErrorMessage;

  @override
  int get hashCode => Object.hash(
    status,
    updateStatus,
    changePasswordStatus,
    user,
    errorMessage,
    updateErrorMessage,
    changePasswordErrorMessage,
  );
}
