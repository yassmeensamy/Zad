import 'package:flutter/widgets.dart';

enum LanguageStatus { initial, loading, success, error }

extension LanguageStatusX on LanguageStatus {
  bool get isLoading => this == LanguageStatus.loading;
  bool get isSuccess => this == LanguageStatus.success;
  bool get isError => this == LanguageStatus.error;
}

class LanguageState {
  final LanguageStatus status;
  final String? selectedLanguage;
  final String? errorMessage;

  LanguageState({
    required this.status,
    this.selectedLanguage,
    this.errorMessage,
  });

  LanguageState copyWith({
    LanguageStatus? status,
    ValueGetter<String?>? selectedLanguage,
    ValueGetter<String?>? errorMessage,
  }) => LanguageState(
    status: status ?? this.status,
    selectedLanguage:
        selectedLanguage != null ? selectedLanguage() : this.selectedLanguage,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  String toString() =>
      'LanguageState(status: $status, selectedLanguage: $selectedLanguage, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageState &&
        other.status == status &&
        other.selectedLanguage == selectedLanguage &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      status.hashCode ^ selectedLanguage.hashCode ^ errorMessage.hashCode;
}
