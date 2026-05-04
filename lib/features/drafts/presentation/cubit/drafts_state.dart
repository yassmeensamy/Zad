import 'package:flutter/foundation.dart';

import '../../data/models/draft_model.dart';

/// Page-level loading status (the GET).
enum DraftsStatus { initial, loading, loaded, error }

/// Side-effect signal for the create / update / delete write-flows. The
/// cubit transitions through `loading -> created|updated|deleted|error`,
/// which lets the UI react with snackbars or navigation without inferring
/// outcomes from the drafts list.
enum CrudStatus { idle, loading, created, updated, deleted, error }

class DraftsState {
  const DraftsState({
    this.status = DraftsStatus.initial,
    this.drafts = const [],
    this.mutatingIds = const {},
    this.errorMessage,
    this.crudStatus = CrudStatus.idle,
    this.crudErrorMessage,
  });

  final DraftsStatus status;
  final List<DraftModel> drafts;

  /// Draft IDs currently being updated or deleted (used to disable per-row UI).
  final Set<int> mutatingIds;
  final String? errorMessage;

  /// Outcome of the most recent write operation. Reset to [CrudStatus.loading]
  /// at the start of every create/update/delete call.
  final CrudStatus crudStatus;
  final String? crudErrorMessage;

  DraftsState copyWith({
    DraftsStatus? status,
    List<DraftModel>? drafts,
    Set<int>? mutatingIds,
    String? Function()? errorMessage,
    CrudStatus? crudStatus,
    String? Function()? crudErrorMessage,
  }) =>
      DraftsState(
        status: status ?? this.status,
        drafts: drafts ?? this.drafts,
        mutatingIds: mutatingIds ?? this.mutatingIds,
        errorMessage:
            errorMessage != null ? errorMessage() : this.errorMessage,
        crudStatus: crudStatus ?? this.crudStatus,
        crudErrorMessage: crudErrorMessage != null
            ? crudErrorMessage()
            : this.crudErrorMessage,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DraftsState &&
        other.status == status &&
        listEquals(other.drafts, drafts) &&
        setEquals(other.mutatingIds, mutatingIds) &&
        other.errorMessage == errorMessage &&
        other.crudStatus == crudStatus &&
        other.crudErrorMessage == crudErrorMessage;
  }

  @override
  int get hashCode => Object.hash(
        status,
        Object.hashAll(drafts),
        Object.hashAllUnordered(mutatingIds),
        errorMessage,
        crudStatus,
        crudErrorMessage,
      );
}

extension DraftsStateX on DraftsState {
  bool get isInitial => status == DraftsStatus.initial;
  bool get isLoading => status == DraftsStatus.loading;
  bool get isLoaded => status == DraftsStatus.loaded;
  bool get isError => status == DraftsStatus.error;

  bool get hasDrafts => drafts.isNotEmpty;
  bool isMutating(int id) => mutatingIds.contains(id);

  bool get isCrudIdle => crudStatus == CrudStatus.idle;
  bool get isCrudLoading => crudStatus == CrudStatus.loading;
  bool get isCrudCreated => crudStatus == CrudStatus.created;
  bool get isCrudUpdated => crudStatus == CrudStatus.updated;
  bool get isCrudDeleted => crudStatus == CrudStatus.deleted;
  bool get isCrudError => crudStatus == CrudStatus.error;

  DraftModel? findByQuestionId(int questionId) {
    for (final d in drafts) {
      if (d.question.id == questionId) return d;
    }
    return null;
  }
}
