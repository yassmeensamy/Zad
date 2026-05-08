import 'package:flutter/foundation.dart';

import '../../data/avatar_model.dart';

enum AvatarsStatus { initial, loading, loaded, error }

class AvatarsState {
  const AvatarsState({
    this.status = AvatarsStatus.initial,
    this.avatars = const [],
    this.errorMessage,
  });

  final AvatarsStatus status;
  final List<AvatarModel> avatars;
  final String? errorMessage;

  AvatarsState copyWith({
    AvatarsStatus? status,
    List<AvatarModel>? avatars,
    String? Function()? errorMessage,
  }) => AvatarsState(
    status: status ?? this.status,
    avatars: avatars ?? this.avatars,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvatarsState &&
        other.status == status &&
        listEquals(other.avatars, avatars) &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    Object.hashAll(avatars),
    errorMessage,
  ]);
}

extension AvatarsStateX on AvatarsState {
  bool get isInitial => status == AvatarsStatus.initial;
  bool get isLoading => status == AvatarsStatus.loading;
  bool get isLoaded => status == AvatarsStatus.loaded;
  bool get isError => status == AvatarsStatus.error;
  bool get hasAvatars => avatars.isNotEmpty;
}
