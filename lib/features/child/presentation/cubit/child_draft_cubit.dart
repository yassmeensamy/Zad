import 'package:uuid/uuid.dart';

import '../../../../core/cubits/base_cubit.dart';
import '../../../onboarding_flow/data/child_avatar.dart';
import 'child_draft_state.dart';

/// Owns the create-profiles form state. Pure presentation — no repository,
/// no network. The screen reads finished drafts from here and hands them
/// off to [ChildCubit] for submission.
class ChildDraftCubit extends BaseCubit<ChildDraftState> {
  ChildDraftCubit() : super(const ChildDraftState());

  final _uuid = const Uuid();

  /// Seed the form with one empty row when first opened.
  void init() {
    if (state.drafts.isNotEmpty) return;
    emit(
      state.copyWith(
        drafts: [ChildDraft(id: _uuid.v4(), avatar: _nextAvatar(const []))],
      ),
    );
  }

  void clear() => emit(const ChildDraftState());

  void addDraft() {
    final draft = ChildDraft(id: _uuid.v4(), avatar: _nextAvatar(state.drafts));
    emit(state.copyWith(drafts: [...state.drafts, draft]));
  }

  void removeDraft(String draftId) {
    emit(
      state.copyWith(
        drafts: state.drafts.where((d) => d.id != draftId).toList(),
      ),
    );
  }

  void updateDraft(
    String draftId, {
    String? name,
    String? age,
    String? password,
    ChildAvatar? avatar,
  }) {
    emit(
      state.copyWith(
        drafts: [
          for (final d in state.drafts)
            if (d.id == draftId)
              d.copyWith(
                name: name,
                age: age,
                password: password,
                avatar: avatar,
              )
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
