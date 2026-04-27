import 'package:flutter/foundation.dart';

import '../../models/child_model.dart';

enum ChildStatus { initial, loading, loaded, error }

enum ChildActionStatus { initial, loading, loaded, error }

class ChildState {
  const ChildState({
    this.status = ChildStatus.initial,
    this.children = const [],
    this.errorMessage,
    this.actionStatus = ChildActionStatus.initial,
    this.actionErrorMessage,
  });

  final ChildStatus status;
  final List<ChildModel> children;
  final String? errorMessage;
  final ChildActionStatus actionStatus;
  final String? actionErrorMessage;

  ChildState copyWith({
    ChildStatus? status,
    List<ChildModel>? children,
    String? Function()? errorMessage,
    ChildActionStatus? actionStatus,
    String? Function()? actionErrorMessage,
  }) => ChildState(
    status: status ?? this.status,
    children: children ?? this.children,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    actionStatus: actionStatus ?? this.actionStatus,
    actionErrorMessage: actionErrorMessage != null
        ? actionErrorMessage()
        : this.actionErrorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildState &&
        other.status == status &&
        listEquals(other.children, children) &&
        other.errorMessage == errorMessage &&
        other.actionStatus == actionStatus &&
        other.actionErrorMessage == actionErrorMessage;
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    Object.hashAll(children),
    errorMessage,
    actionStatus,
    actionErrorMessage,
  ]);
}

extension ChildStateX on ChildState {
  bool get isInitial => status == ChildStatus.initial;
  bool get isLoading => status == ChildStatus.loading;
  bool get isLoaded => status == ChildStatus.loaded;
  bool get isError => status == ChildStatus.error;

  bool get isActionInitial => actionStatus == ChildActionStatus.initial;
  bool get isActionLoading => actionStatus == ChildActionStatus.loading;
  bool get isActionLoaded => actionStatus == ChildActionStatus.loaded;
  bool get isActionError => actionStatus == ChildActionStatus.error;

  bool get hasChildren => children.isNotEmpty;
}
