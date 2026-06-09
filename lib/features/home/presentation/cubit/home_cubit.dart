import 'dart:async';

import 'package:event_bus/event_bus.dart';

import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/events/app_events.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit({required HomeRepository homeRepository, required EventBus eventBus})
    : _homeRepository = homeRepository,
      super(const HomeState()) {
    _langSub = eventBus.on<LanguageChangedEvent>().listen((e) {
      logger.debug(
        '🏠 [home] got LanguageChangedEvent(${e.languageCode}) '
        'status=${state.status} → ${state.isInitial ? "SKIP (initial)" : "refetch"}',
      );
      getOverview(refresh: true);
    });
  }

  final HomeRepository _homeRepository;
  StreamSubscription<LanguageChangedEvent>? _langSub;

  Future<void> getOverview({bool refresh = false}) async {
    if (!refresh) {
      emit(
        state.copyWith(
          status: HomeStatus.loading,
          errorMessage: () => null,
        ),
      );
    }
    try {
      final overview = await _homeRepository.getOverview();
      emit(
        state.copyWith(status: HomeStatus.loaded, overview: overview),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('HomeCubit.getOverview failed: $e');
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: () => 'home.load_failed',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _langSub?.cancel();
    return super.close();
  }
}
