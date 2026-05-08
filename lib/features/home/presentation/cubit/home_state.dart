import '../../data/models/home_overview_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.overview,
    this.errorMessage,
  });

  final HomeStatus status;
  final HomeOverviewModel? overview;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    HomeOverviewModel? overview,
    String? Function()? errorMessage,
  }) => HomeState(
    status: status ?? this.status,
    overview: overview ?? this.overview,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeState &&
        other.status == status &&
        other.overview == overview &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, overview, errorMessage);
}

extension HomeStateX on HomeState {
  bool get isInitial => status == HomeStatus.initial;
  bool get isLoading => status == HomeStatus.loading;
  bool get isLoaded => status == HomeStatus.loaded;
  bool get isError => status == HomeStatus.error;

  bool get hasOverview => overview != null;
}
