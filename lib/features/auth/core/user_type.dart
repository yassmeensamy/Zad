enum UserType { user, guestUser }

extension UserTypeX on UserType {
  bool get isGuest => this == UserType.guestUser;
  bool get isUser => this == UserType.user;
}
