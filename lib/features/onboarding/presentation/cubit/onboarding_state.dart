import '../../data/models/onboarding_model.dart';

enum OnboardingStatus { initial, loading, error, success }

extension OnboardingStateX on OnboardingState {
  bool get isInitial => status == OnboardingStatus.initial;
  bool get isLoading => status == OnboardingStatus.loading;
  bool get isError => status == OnboardingStatus.error;
  bool get isSuccess => status == OnboardingStatus.success;
}

class OnboardingState {
  const OnboardingState({
    required this.status,
    this.pages = const [],
    this.currentPage = 0,
    this.errorMessage,
  });

  final OnboardingStatus status;
  final List<OnboardingModel> pages;
  final int currentPage;
  final String? errorMessage;

  OnboardingState copyWith({
    OnboardingStatus? status,
    List<OnboardingModel>? pages,
    int? currentPage,
    String? errorMessage,
  }) => OnboardingState(
    status: status ?? this.status,
    pages: pages ?? this.pages,
    currentPage: currentPage ?? this.currentPage,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          other.status == status &&
          other.pages == pages &&
          other.currentPage == currentPage &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      Object.hash(status, pages, currentPage, errorMessage);
}
