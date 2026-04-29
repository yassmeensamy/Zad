import 'package:flutter/foundation.dart';

import '../../../onboarding_flow/data/child_avatar.dart';

/// Holds the in-progress drafts the user is editing.
///
/// [originals] is a snapshot of drafts as last loaded from the server —
/// keys are server-known ids, values are originals to compare against
/// for dirty detection.
class ChildDraftState {
  const ChildDraftState({
    this.drafts = const [],
    this.originals = const {},
    this.pendingDeletes = const [],
    this.validationError,
  });

  final List<ChildDraft> drafts;
  final Map<String, ChildDraft> originals;
  final List<String> pendingDeletes;
  final String? validationError;

  ChildDraftState copyWith({
    List<ChildDraft>? drafts,
    Map<String, ChildDraft>? originals,
    List<String>? pendingDeletes,
    String? validationError,
    bool resetValidationError = false,
  }) => ChildDraftState(
    drafts: drafts ?? this.drafts,
    originals: originals ?? this.originals,
    pendingDeletes: pendingDeletes ?? this.pendingDeletes,
    validationError: resetValidationError
        ? null
        : (validationError ?? this.validationError),
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildDraftState &&
        listEquals(other.drafts, drafts) &&
        mapEquals(other.originals, originals) &&
        listEquals(other.pendingDeletes, pendingDeletes) &&
        other.validationError == validationError;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(drafts),
    Object.hashAll(originals.entries),
    Object.hashAll(pendingDeletes),
    validationError,
  );
}

extension ChildDraftStateX on ChildDraftState {
  bool get hasDrafts => drafts.isNotEmpty;

  /// Drafts the user has actually started filling in (i.e. given a name).
  List<ChildDraft> get namedDrafts =>
      drafts.where((d) => d.name.trim().isNotEmpty).toList();

  bool isServerKnown(String id) => originals.containsKey(id);

  bool isDirty(ChildDraft d) {
    final original = originals[d.id];
    if (original == null) return d.name.trim().isNotEmpty;
    return d.name != original.name ||
        d.age != original.age ||
        d.password != original.password ||
        d.avatar != original.avatar;
  }

  List<ChildDraft> get newDrafts => drafts
      .where((d) => !isServerKnown(d.id) && d.name.trim().isNotEmpty)
      .toList();

  List<ChildDraft> get dirtyExisting =>
      drafts.where((d) => isServerKnown(d.id) && isDirty(d)).toList();

  bool get hasPending =>
      pendingDeletes.isNotEmpty ||
      drafts.any((d) => !isServerKnown(d.id) || isDirty(d));
}
