/// Firebase Remote Config parameter keys.
///
/// Create these parameters in the Firebase console (Remote Config) with a
/// semver string value, e.g. `1.2.0`. They hold the minimum installed app
/// version allowed per platform; anything older is force-updated.
abstract class RemoteConfigKeys {
  static const String clientMinVersionIos = 'client_min_version_ios';
  static const String clientMinVersionAndroid = 'client_min_version_android';
}
