import 'package:location/location.dart';

class LocationCoordinates {
  final double latitude, longitude;

  LocationCoordinates(this.latitude, this.longitude);
}

class LocationManager {
  var location = new Location();

  Future<LocationCoordinates> canGetLocation() async {
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
