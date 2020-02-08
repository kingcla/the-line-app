import 'package:location/location.dart';

class LocationCoordinates {
  final double latitude, longitude;

  LocationCoordinates(this.latitude, this.longitude);
}

abstract class ILocationManager {
  /// Return the [LocationCoordinates] of the current goe position.
  /// It will return null if there was a problem retrieving the latitude and longitude
  /// or the user did not give permission to access location.
  Future<LocationCoordinates> getLocation();
}

class LocationManager implements ILocationManager {
  var location = new Location();

  @override
  Future<LocationCoordinates> getLocation() async {
    if (!await location.hasPermission()) {
      // try request ermission
      if (!await location.requestPermission()) {
        return null;
      }
    }

    if (!await location.serviceEnabled()) {
      // try enable the location services
      if (!await location.requestService()) {
        return null;
      }
    }

    LocationData currentLocation = await location.getLocation();

    var pos = LocationCoordinates(
        currentLocation.latitude, currentLocation.longitude);

    return pos;
  }
}
