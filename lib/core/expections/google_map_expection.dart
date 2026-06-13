abstract class AppLocationException implements Exception {
  AppLocationException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

//request permission again
class LocationDeniedException extends AppLocationException {
  LocationDeniedException(super.message);
}

//Geolocator.openAppSettings(
class LocationDeniedForEverException extends AppLocationException {
  LocationDeniedForEverException(super.message);
}

/// go to settings and enable location services (location services)
class LocationServicesDisabledException extends AppLocationException {
  LocationServicesDisabledException(super.message);
}
