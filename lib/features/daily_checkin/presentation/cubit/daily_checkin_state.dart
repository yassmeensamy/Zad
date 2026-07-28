import '../../data/models/daily_checkin_model.dart';

enum DailyCheckInStatus { initial, loading, loaded, error }

class DailyCheckInState {
  const DailyCheckInState({
    this.status = DailyCheckInStatus.initial,
    this.result,
    this.errorMessage,
  });

  final DailyCheckInStatus status;
  final DailyCheckInModel? result;
  final String? errorMessage;

  DailyCheckInState copyWith({
    DailyCheckInStatus? status,
    DailyCheckInModel? result,
    String? Function()? errorMessage,
  }) => DailyCheckInState(
    status: status ?? this.status,
    result: result ?? this.result,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyCheckInState &&
        other.status == status &&
        other.result == result &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, result, errorMessage);
}

extension DailyCheckInStateX on DailyCheckInState {
  bool get isInitial => status == DailyCheckInStatus.initial;
  bool get isLoading => status == DailyCheckInStatus.loading;
  bool get isLoaded => status == DailyCheckInStatus.loaded;
  bool get isError => status == DailyCheckInStatus.error;

  bool get pointAwarded => result?.pointAwarded ?? false;

  int get totalPoints => result?.totalPoints ?? 0;

  DateTime? get checkInDate => result?.checkInDate;

  String? get message => result?.message;
}
