abstract class AppStorageException implements Exception {
  AppStorageException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// When storage permission is denied by user
class StoragePermissionDeniedException extends AppStorageException {
  StoragePermissionDeniedException(super.message);
}

/// When storage permission is permanently denied by user
/// User needs to go to settings to enable it
class StoragePermissionDeniedForeverException extends AppStorageException {
  StoragePermissionDeniedForeverException(super.message);
}

/// When storage permission is restricted (e.g., on Android 11+ with scoped storage)
class StoragePermissionRestrictedException extends AppStorageException {
  StoragePermissionRestrictedException(super.message);
}

/// When there's an error during permission request
class StoragePermissionRequestException extends AppStorageException {
  StoragePermissionRequestException(super.message);
}
