import '../../data/models/quran_sign_model.dart';

enum QuranSignStatus { initial, loading, loaded, error }

class QuranSignState {
  const QuranSignState({
    this.status = QuranSignStatus.initial,
    this.sign,
    this.errorMessage,
  });

  final QuranSignStatus status;
  final QuranSignModel? sign;
  final String? errorMessage;

  QuranSignState copyWith({
    QuranSignStatus? status,
    QuranSignModel? sign,
    String? Function()? errorMessage,
  }) => QuranSignState(
    status: status ?? this.status,
    sign: sign ?? this.sign,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuranSignState &&
        other.status == status &&
        other.sign == sign &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, sign, errorMessage);
}

extension QuranSignStateX on QuranSignState {
  bool get isInitial => status == QuranSignStatus.initial;
  bool get isLoading => status == QuranSignStatus.loading;
  bool get isLoaded => status == QuranSignStatus.loaded;
  bool get isError => status == QuranSignStatus.error;

  bool get hasSign => sign != null;
}
