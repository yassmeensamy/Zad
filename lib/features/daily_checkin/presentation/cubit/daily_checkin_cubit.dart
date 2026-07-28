import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/daily_checkin_repository.dart';
import 'daily_checkin_state.dart';

class DailyCheckInCubit extends BaseCubit<DailyCheckInState> {
  DailyCheckInCubit({required DailyCheckInRepository repository})
    : _repository = repository,
      super(const DailyCheckInState());

  final DailyCheckInRepository _repository;

  bool _inFlight = false;

  Future<void> checkIn() async {
    if (_inFlight) return;
    _inFlight = true;
    emit(
      state.copyWith(
        status: DailyCheckInStatus.loading,
        errorMessage: () => null,
      ),
    );
    try {
      final result = await _repository.checkIn();
      emit(
        state.copyWith(
          status: DailyCheckInStatus.loaded,
          result: result,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: DailyCheckInStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('DailyCheckInCubit.checkIn failed: $e');
      emit(
        state.copyWith(
          status: DailyCheckInStatus.error,
          errorMessage: () => 'daily_checkin.failed',
        ),
      );
    } finally {
      _inFlight = false;
    }
  }
}
