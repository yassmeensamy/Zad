abstract class AppPhonePermissionException implements Exception {
  AppPhonePermissionException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class PhonePermissionDeniedException extends AppPhonePermissionException {
  PhonePermissionDeniedException(super.message);
}

class PhonePermissionDeniedForeverException
    extends AppPhonePermissionException {
  PhonePermissionDeniedForeverException(super.message);
}
