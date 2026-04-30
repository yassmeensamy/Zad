import '../../../../core/cubits/base_cubit.dart';
import '../../../../core/expections/server_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/support_request_model.dart';
import '../../data/repositories/help_center_repository.dart';
import 'help_center_state.dart';

class HelpCenterCubit extends BaseCubit<HelpCenterState> {
  HelpCenterCubit({required HelpCenterRepository helpCenterRepository})
    : _helpCenterRepository = helpCenterRepository,
      super(const HelpCenterState());

  final HelpCenterRepository _helpCenterRepository;

  void selectTopic(SupportTopicEnum topic) {
    if (state.isSending) return;
    final next = state.topic == topic ? null : topic;
    emit(state.copyWith(topic: () => next, errorMessage: () => null));
  }

  void updateSubject(String value) {
    emit(state.copyWith(subject: value));
  }

  void updateMessage(String value) {
    emit(state.copyWith(message: value));
  }

  Future<void> submit() async {
    if (!state.canSubmit || state.topic == null) return;

    emit(
      state.copyWith(
        status: HelpCenterStatus.sending,
        errorMessage: () => null,
      ),
    );

    try {
      final sent = await _helpCenterRepository.sendSupportRequest(
        SupportRequestModel(
          topic: state.topic!,
          subject: state.subject.trim(),
          message: state.message.trim(),
        ),
      );
      emit(
        state.copyWith(
          status: HelpCenterStatus.sent,
          lastSent: () => sent,
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: HelpCenterStatus.error,
          errorMessage: () => e.message,
        ),
      );
    } catch (e) {
      logger.error('HelpCenterCubit.submit failed: $e');
      emit(
        state.copyWith(
          status: HelpCenterStatus.error,
          errorMessage: () => 'help_center.send_failed',
        ),
      );
    }
  }

  void resetForm() {
    emit(const HelpCenterState());
  }

  void dismissError() {
    if (!state.isError) return;
    emit(
      state.copyWith(
        status: HelpCenterStatus.idle,
        errorMessage: () => null,
      ),
    );
  }
}
