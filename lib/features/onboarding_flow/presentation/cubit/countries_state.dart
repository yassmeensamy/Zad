import 'package:flutter/foundation.dart';

import '../../data/country_model.dart';

enum CountriesStatus { initial, loading, loaded, error }

class CountriesState {
  const CountriesState({
    this.status = CountriesStatus.initial,
    this.countries = const [],
    this.errorMessage,
  });

  final CountriesStatus status;
  final List<CountryModel> countries;
  final String? errorMessage;

  CountriesState copyWith({
    CountriesStatus? status,
    List<CountryModel>? countries,
    String? Function()? errorMessage,
  }) => CountriesState(
    status: status ?? this.status,
    countries: countries ?? this.countries,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountriesState &&
        other.status == status &&
        listEquals(other.countries, countries) &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    Object.hashAll(countries),
    errorMessage,
  ]);
}

extension CountriesStateX on CountriesState {
  bool get isInitial => status == CountriesStatus.initial;
  bool get isLoading => status == CountriesStatus.loading;
  bool get isLoaded => status == CountriesStatus.loaded;
  bool get isError => status == CountriesStatus.error;
  bool get hasCountries => countries.isNotEmpty;
}
