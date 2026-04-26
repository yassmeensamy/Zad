abstract class AppMicrophonePermissionException implements Exception {
  AppMicrophonePermissionException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class MicrophonePermissionDeniedException
    extends AppMicrophonePermissionException {
  MicrophonePermissionDeniedException(super.message);
}

class MicrophonePermissionDeniedForeverException
    extends AppMicrophonePermissionException {
  MicrophonePermissionDeniedForeverException(super.message);
}
