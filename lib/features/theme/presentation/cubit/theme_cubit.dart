import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Persists the user's preferred [ThemeMode] across launches.
///
/// State is hydrated automatically by [HydratedCubit], so the chosen
/// appearance survives app restarts without any manual storage wiring.
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) => emit(mode);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final name = json['themeMode'] as String?;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'themeMode': state.name};
}
