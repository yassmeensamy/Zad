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

class GoogleCustomException extends AppLocationException {
  GoogleCustomException(super.message, {this.code});
  final int? code;
}

//Geolocator.openAppSettings(
class LocationDeniedForEverException extends AppLocationException {
  LocationDeniedForEverException(super.message);
}

/// go to settings and enable location services (location services)
class LocationServicesDisabledException extends AppLocationException {
  LocationServicesDisabledException(super.message);
}

/// When fetching static map image fails.
class FetchStaticMapImageException extends AppLocationException {
  FetchStaticMapImageException(super.message);
}

class RouteFetchingException extends AppLocationException {
  RouteFetchingException(super.message);
}
