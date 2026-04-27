import 'package:flutter/foundation.dart';

import '../../../onboarding_flow/data/child_avatar.dart';

/// Holds the in-progress drafts the user is editing in the
/// create-profiles form. Lives only as long as that screen.
class ChildDraftState {
  const ChildDraftState({this.drafts = const []});

  final List<ChildDraft> drafts;

  ChildDraftState copyWith({List<ChildDraft>? drafts}) =>
      ChildDraftState(drafts: drafts ?? this.drafts);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildDraftState && listEquals(other.drafts, drafts);
  }

  @override
  int get hashCode => Object.hashAll(drafts);
}

extension ChildDraftStateX on ChildDraftState {
  bool get hasDrafts => drafts.isNotEmpty;

  /// Drafts the user has actually started filling in (i.e. given a name).
  List<ChildDraft> get namedDrafts =>
      drafts.where((d) => d.name.trim().isNotEmpty).toList();
}
