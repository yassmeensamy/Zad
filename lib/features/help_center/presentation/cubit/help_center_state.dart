import '../../data/models/support_request_model.dart';

enum HelpCenterStatus { idle, sending, sent, error }

class HelpCenterState {
  const HelpCenterState({
    this.status = HelpCenterStatus.idle,
    this.topic,
    this.subject = '',
    this.message = '',
    this.errorMessage,
    this.lastSent,
  });

  final HelpCenterStatus status;
  final SupportTopicEnum? topic;
  final String subject;
  final String message;
  final String? errorMessage;
  final SupportRequestModel? lastSent;

  HelpCenterState copyWith({
    HelpCenterStatus? status,
    SupportTopicEnum? Function()? topic,
    String? subject,
    String? message,
    String? Function()? errorMessage,
    SupportRequestModel? Function()? lastSent,
  }) => HelpCenterState(
    status: status ?? this.status,
    topic: topic != null ? topic() : this.topic,
    subject: subject ?? this.subject,
    message: message ?? this.message,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    lastSent: lastSent != null ? lastSent() : this.lastSent,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HelpCenterState &&
        other.status == status &&
        other.topic == topic &&
        other.subject == subject &&
        other.message == message &&
        other.errorMessage == errorMessage &&
        other.lastSent == lastSent;
  }

  @override
  int get hashCode =>
      Object.hash(status, topic, subject, message, errorMessage, lastSent);
}

extension HelpCenterStateX on HelpCenterState {
  bool get isIdle => status == HelpCenterStatus.idle;
  bool get isSending => status == HelpCenterStatus.sending;
  bool get isSent => status == HelpCenterStatus.sent;
  bool get isError => status == HelpCenterStatus.error;

  bool get canSubmit =>
      topic != null && message.trim().isNotEmpty && !isSending;
}
