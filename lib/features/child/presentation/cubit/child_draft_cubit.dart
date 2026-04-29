import 'package:uuid/uuid.dart';

import '../../../../core/cubits/base_cubit.dart';
import '../../../onboarding_flow/data/child_avatar.dart';
import '../../models/child_model.dart';
import 'child_draft_state.dart';

class ChildDraftCubit extends BaseCubit<ChildDraftState> {
  ChildDraftCubit() : super(const ChildDraftState());

  final _uuid = const Uuid();

  void init() {
    if (state.drafts.isNotEmpty) return;
    emit(
      state.copyWith(
        drafts: [ChildDraft(id: _uuid.v4(), avatar: _nextAvatar(const []))],
      ),
    );
  }

  void clear() => emit(const ChildDraftState());

  void setDrafts(List<ChildDraft> drafts) =>
      emit(state.copyWith(drafts: drafts));

  void loadFromServer(List<ChildModel> children) {
    final emitted = [
      for (final c in children)
        ChildDraft(
          id: c.id,
          name: c.fullName,
          age: c.age?.toString() ?? '',
          password: '••••',
        ),
    ];
    emit(
      ChildDraftState(
        drafts: emitted,
        originals: {for (final d in emitted) d.id: d},
      ),
    );
  }

  bool validate() {
    final invalid = state.drafts.any(
      (d) =>
          !state.isServerKnown(d.id) &&
          d.name.trim().isNotEmpty &&
          (d.password.isEmpty || d.password == '••••'),
    );
    if (invalid) {
      emit(state.copyWith(validationError: 'children_list.password_required'));
      return false;
    }
    return true;
  }

  void clearError() {
    if (state.validationError == null) return;
    emit(state.copyWith(resetValidationError: true));
  }

  void add() {
    final draft = ChildDraft(id: _uuid.v4(), avatar: _nextAvatar(state.drafts));
    emit(state.copyWith(drafts: [...state.drafts, draft]));
  }

  void remove(String id) {
    final wasServerKnown = state.originals.containsKey(id);
    emit(
      state.copyWith(
        drafts: state.drafts.where((d) => d.id != id).toList(),
        originals: wasServerKnown
            ? ({...state.originals}..remove(id))
            : state.originals,
        pendingDeletes: wasServerKnown
            ? [...state.pendingDeletes, id]
            : state.pendingDeletes,
      ),
    );
  }

  void update(
    String id, {
    String? name,
    String? age,
    String? password,
    ChildAvatar? avatar,
  }) {
    emit(
      state.copyWith(
        drafts: [
          for (final d in state.drafts)
            if (d.id == id)
              d.copyWith(name: name, age: age, password: password, avatar: avatar)
            else
              d,
        ],
      ),
    );
  }

  ChildAvatar _nextAvatar(List<ChildDraft> existing) {
    final used = existing.map((d) => d.avatar).toSet();
    return ChildAvatar.values.firstWhere(
      (a) => !used.contains(a),
      orElse: () => ChildAvatar.values.first,
    );
  }
}
