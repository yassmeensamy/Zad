import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/child_repository.dart';
import '../../models/child_model.dart';
import 'child_state.dart';

/// Payload accepted by [ChildCubit.createChildren]. Kept as a record so
/// the cubit doesn't have to know about [ChildDraft] (presentation type).
typedef NewChild = ({
  String username,
  String fullName,
  String password,
  DateTime? birthDate,
});

class ChildCubit extends BaseCubit<ChildState> {
  ChildCubit({required ChildRepository childRepository})
    : _childRepository = childRepository,
      super(const ChildState());

  final ChildRepository _childRepository;

  Future<void> fetchChildren() async {
    emit(state.copyWith(status: ChildStatus.loading, errorMessage: () => null));
    try {
      final children = await _childRepository.getChildren();
      emit(state.copyWith(status: ChildStatus.loaded, children: children));
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: ChildStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('ChildCubit.fetchChildren failed: $e');
      emit(
        state.copyWith(
          status: ChildStatus.error,
          errorMessage: () => 'Failed to load children',
        ),
      );
    }
  }

  Future<void> createChild({
    required String username,
    required String fullName,
    required String password,
    DateTime? birthDate,
  }) async {
    emit(
      state.copyWith(
        actionStatus: ChildActionStatus.loading,
        actionErrorMessage: () => null,
      ),
    );
    try {
      final created = await _childRepository.createChild(
        username: username,
        fullName: fullName,
        password: password,
        birthDate: birthDate,
      );
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.loaded,
          children: [...state.children, created],
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.error,
          actionErrorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('ChildCubit.createChild failed: $e');
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.error,
          actionErrorMessage: () => 'Failed to create child',
        ),
      );
    }
  }

  /// Bulk-create children — used by the create-profiles form. Loops
  /// sequentially so the server sees one create at a time. The last error
  /// (if any) is surfaced via [actionErrorMessage]; successful creates
  /// land in [children] regardless.
  Future<void> createChildren(List<NewChild> children) async {
    if (children.isEmpty) return;
    emit(
      state.copyWith(
        actionStatus: ChildActionStatus.loading,
        actionErrorMessage: () => null,
      ),
    );

    final created = <ChildModel>[];
    String? lastError;

    for (final c in children) {
      try {
        final model = await _childRepository.createChild(
          username: c.username,
          fullName: c.fullName,
          password: c.password,
          birthDate: c.birthDate,
        );
        created.add(model);
      } on ServerException catch (e) {
        lastError = e.message;
      } catch (e) {
        logger.error('ChildCubit.createChildren failed: $e');
        lastError = 'Failed to create ${c.fullName}';
      }
    }

    emit(
      state.copyWith(
        actionStatus: lastError == null
            ? ChildActionStatus.loaded
            : ChildActionStatus.error,
        actionErrorMessage: () => lastError,
        children: [...state.children, ...created],
      ),
    );
  }

  Future<void> updateChild({
    required String childId,
    String? username,
    String? fullName,
    DateTime? birthDate,
    String? password, // won't be sent if null, but if non-null it will be updated
  }) async {
    emit(
      state.copyWith(
        actionStatus: ChildActionStatus.loading,
        actionErrorMessage: () => null,
      ),
    );
    try {
      final updated = await _childRepository.updateChild(
        childId: childId,
        username: username,
        fullName: fullName,
        birthDate: birthDate,
        password: password,
      );
      final updatedList = [
        for (final c in state.children)
          if (c.id == updated.id) updated else c,
      ];
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.loaded,
          children: updatedList,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.error,
          actionErrorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('ChildCubit.updateChild failed: $e');
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.error,
          actionErrorMessage: () => 'Failed to update child',
        ),
      );
    }
  }

  Future<void> deleteChild(String childId) async {
    emit(
      state.copyWith(
        actionStatus: ChildActionStatus.loading,
        actionErrorMessage: () => null,
      ),
    );
    try {
      await _childRepository.deleteChild(childId);
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.loaded,
          children: state.children.where((c) => c.id != childId).toList(),
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.error,
          actionErrorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('ChildCubit.deleteChild failed: $e');
      emit(
        state.copyWith(
          actionStatus: ChildActionStatus.error,
          actionErrorMessage: () => 'Failed to delete child',
        ),
      );
    }
  }

  void resetActionStatus() {
    emit(
      state.copyWith(
        actionStatus: ChildActionStatus.initial,
        actionErrorMessage: () => null,
      ),
    );
  }
}
