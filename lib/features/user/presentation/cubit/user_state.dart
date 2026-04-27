import '../../../../core/models/user_model.dart';

enum UserStatus { initial, loading, success, error }

extension UserStatusX on UserState {
  bool get isInitial => status == UserStatus.initial;
  bool get isLoading => status == UserStatus.loading;
  bool get isSuccess => status == UserStatus.success;
  bool get isError => status == UserStatus.error;
}

class UserState {
  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
  });

  final UserStatus status;
  final UserModel? user;
  final String? errorMessage;

  UserState copyWith({
    UserStatus? status,
    UserModel? user,
    String? errorMessage,
  }) => UserState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserState &&
          other.status == status &&
          other.user == user &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(status, user, errorMessage);
}
