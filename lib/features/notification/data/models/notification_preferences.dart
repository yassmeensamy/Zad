import 'package:flutter/foundation.dart';

/// Per-channel delivery preference for a single notification type.
///
/// Mirrors the `{ "push": bool, "inApp": bool }` object the
/// `/api/notifications/preferences` endpoint returns/accepts for each
/// `NotificationType` key. Both channels default to enabled, matching the
/// backend's "all-enabled when no record exists" behaviour.
@immutable
class NotificationChannelPreference {
  const NotificationChannelPreference({this.push = true, this.inApp = true});

  /// Whether system/push delivery is enabled for this type.
  final bool push;

  /// Whether the in-app inbox surfaces this type.
  final bool inApp;

  factory NotificationChannelPreference.fromMap(Map<String, dynamic> map) =>
      NotificationChannelPreference(
        push: map['push'] as bool? ?? true,
        inApp: map['inApp'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {'push': push, 'inApp': inApp};

  NotificationChannelPreference copyWith({bool? push, bool? inApp}) =>
      NotificationChannelPreference(
        push: push ?? this.push,
        inApp: inApp ?? this.inApp,
      );

  @override
  bool operator ==(Object other) =>
      other is NotificationChannelPreference &&
      other.push == push &&
      other.inApp == inApp;

  @override
  int get hashCode => Object.hash(push, inApp);
}

/// The user's per-type notification preferences, keyed by `NotificationType`.
///
/// The backend rejects unknown keys, so the map returned by GET is the source
/// of truth for which types exist; mutations preserve those exact keys and only
/// flip channel flags.
@immutable
class NotificationPreferences {
  const NotificationPreferences(this.byType);

  const NotificationPreferences.empty() : byType = const {};

  final Map<String, NotificationChannelPreference> byType;

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) =>
      NotificationPreferences({
        for (final entry in map.entries)
          entry.key: NotificationChannelPreference.fromMap(
            (entry.value as Map).cast<String, dynamic>(),
          ),
      });

  Map<String, dynamic> toMap() => {
    for (final entry in byType.entries) entry.key: entry.value.toMap(),
  };

  bool get isEmpty => byType.isEmpty;

  /// True when at least one type still delivers on any channel — the signal the
  /// master toggle reflects. `push` and `inApp` move together, so either flag
  /// being on means the type is enabled.
  bool get anyEnabled => byType.values.any((p) => p.push || p.inApp);

  /// Returns a copy with **both** channels (`push` and `inApp`) set to [value]
  /// for every type — the master toggle treats them as one switch: all on, or
  /// all off.
  NotificationPreferences withAll(bool value) => NotificationPreferences({
    for (final entry in byType.entries)
      entry.key: entry.value.copyWith(push: value, inApp: value),
  });

  @override
  bool operator ==(Object other) =>
      other is NotificationPreferences && mapEquals(other.byType, byType);

  @override
  int get hashCode =>
      Object.hashAll([for (final e in byType.entries) Object.hash(e.key, e.value)]);
}
