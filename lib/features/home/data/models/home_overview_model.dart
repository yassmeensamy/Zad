import 'hadith_model.dart';

/// Composite payload for the home screen. Future home-only widgets (e.g. ayah
/// of the day, daily goal) can be added here without growing the cubit's
/// surface.
class HomeOverviewModel {
  const HomeOverviewModel({required this.hadithOfDay});

  final HadithModel hadithOfDay;

  HomeOverviewModel copyWith({HadithModel? hadithOfDay}) =>
      HomeOverviewModel(hadithOfDay: hadithOfDay ?? this.hadithOfDay);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeOverviewModel && other.hadithOfDay == hadithOfDay;
  }

  @override
  int get hashCode => hadithOfDay.hashCode;
}
