import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/avatars_repository.dart';
import 'avatars_state.dart';

class AvatarsCubit extends BaseCubit<AvatarsState> {
  AvatarsCubit({required AvatarsRepository avatarsRepository})
    : _avatarsRepository = avatarsRepository,
      super(const AvatarsState());

  final AvatarsRepository _avatarsRepository;

  Future<void> fetchAvatars() async {
    if (state.isLoading) return;
    emit(state.copyWith(status: AvatarsStatus.loading, errorMessage: () => null));
    try {
      final avatars = await _avatarsRepository.getAvatars();
      emit(
        state.copyWith(status: AvatarsStatus.loaded, avatars: avatars),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: AvatarsStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('AvatarsCubit.fetchAvatars failed: $e');
      emit(
        state.copyWith(
          status: AvatarsStatus.error,
          errorMessage: () => 'errors.generic',
        ),
      );
    }
  }
}
