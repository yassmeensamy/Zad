abstract class AppPhotosPermissionException implements Exception {
  AppPhotosPermissionException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class PhotosPermissionDeniedException extends AppPhotosPermissionException {
  PhotosPermissionDeniedException(super.message);
}

class PhotosPermissionDeniedForeverException
    extends AppPhotosPermissionException {
  PhotosPermissionDeniedForeverException(super.message);
}
