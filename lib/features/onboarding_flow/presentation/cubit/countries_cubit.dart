import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/countries_repository.dart';
import 'countries_state.dart';

class CountriesCubit extends BaseCubit<CountriesState> {
  CountriesCubit({required CountriesRepository countriesRepository})
    : _countriesRepository = countriesRepository,
      super(const CountriesState());

  final CountriesRepository _countriesRepository;

  Future<void> fetchCountries() async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        status: CountriesStatus.loading,
        errorMessage: () => null,
      ),
    );
    try {
      final countries = await _countriesRepository.getCountries();
      emit(
        state.copyWith(status: CountriesStatus.loaded, countries: countries),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: CountriesStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('CountriesCubit.fetchCountries failed: $e');
      emit(
        state.copyWith(
          status: CountriesStatus.error,
          errorMessage: () => 'errors.generic',
        ),
      );
    }
  }
}
