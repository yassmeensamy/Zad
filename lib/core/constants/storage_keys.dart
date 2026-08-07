/// Storage Keys - Contains all local storage key constants
class StorageKeys {
  static const String kRunBeforeKey = 'run_before';
  static const String kSessionIdKey = 'session_id';
  static const String kCustomerDataKey = 'customer_data';
  static const String kLocaleKey = 'locale';
  static const String kFirstOpenKey = 'first_open';
  static const String kLoginMethodKey = 'login_method';
  static const String kAccessTokenKey = 'access_token';
  static const String kRefreshTokenKey = 'refresh_token';
  static const String kUserKey = 'user_profile';

  /// Name handed over by a social provider at sign-in. Apple only returns it on
  /// the very first authorization, so it's stashed here and takes precedence
  /// over whatever /me reports until the user saves a profile of their own.
  static const String kPendingSocialNameKey = 'pending_social_name';
}
