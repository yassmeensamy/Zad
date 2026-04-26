abstract class AppBluetoothPermissionException implements Exception {
  AppBluetoothPermissionException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class BluetoothPermissionDeniedException
    extends AppBluetoothPermissionException {
  BluetoothPermissionDeniedException(super.message);
}

class BluetoothPermissionDeniedForeverException
    extends AppBluetoothPermissionException {
  BluetoothPermissionDeniedForeverException(super.message);
}
