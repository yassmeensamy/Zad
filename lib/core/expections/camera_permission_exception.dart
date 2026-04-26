abstract class AppCameraPermissionException implements Exception {
  AppCameraPermissionException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class CameraPermissionDeniedException extends AppCameraPermissionException {
  CameraPermissionDeniedException(super.message);
}

class CameraPermissionDeniedForeverException
    extends AppCameraPermissionException {
  CameraPermissionDeniedForeverException(super.message);
}
