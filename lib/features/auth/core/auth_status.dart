enum AuthStatus { initial, loading, loggedIn, notLoggedIn, error, guest }

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;
  bool get isLoading => this == AuthStatus.loading;
  bool get isLoggedIn => this == AuthStatus.loggedIn;
  bool get isNotLoggedIn => this == AuthStatus.notLoggedIn;
  bool get isError => this == AuthStatus.error;
  bool get isGuest => this == AuthStatus.guest;
}


enum AuthEvent { loggedIn, userReady, loggedOut, guest }
