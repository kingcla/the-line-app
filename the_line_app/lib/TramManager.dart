import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

class MapCoordinates {
  double x, y;
  MapCoordinates(this.x, this.y);
  factory MapCoordinates.fromJson(Map<String, dynamic> data) {
    return MapCoordinates(data['xCoordinaat'], data['yCoordinaat']);
  }
}

class TramStation {
  num id;
  String description;
  String problems; // in case of strike or other disturbance
  List<String> destinations;
  List<Line> lines;
  List<TimeTable> timetables;

  TramStation(this.id,
      {this.description, this.problems, this.destinations, this.lines});

  factory TramStation.fromJson(Map<String, dynamic> data) {
    return TramStation(data['halteNummer'], description: data['']);
  }
}

class Line {
  String destination;
  num linenumber;
  String color;
}

class TimeTable {
  Line line;
  DateTime coming;
}

class TramManager {
  final int _range = 100; //100 meters range as default
  final String _locationURL =
      'https://www.delijn.be/rise-api-core/coordinaten/convert/';
  final String _getStationURL =
      'https://www.delijn.be/rise-api-core/haltes/indebuurt/';

  Future<TramStation> getNearestStation(double latitude, double longitude,
      {int range = 100}) async {
    var client = http.Client();
    try {
      // First we need to convert the geo coordinates {latitude,longite}
      // into DeLijn map coordinates {x,y}
      var response = await client.get(
        _locationURL + latitude.toString() + '/' + longitude.toString(),
      );

      if (!_checkResponse(response)) {
        return null;
      }

      var parsed = json.decode(response.body);
      MapCoordinates coo = MapCoordinates.fromJson(parsed);

      // Now that we have the x-y location converted
      // we do another request for the closer tram station
      response = await client.get(_getStationURL +
          coo.x.toString() +
          '/' +
          coo.y.toString() +
          '/' +
          range.toString());

      if (!_checkResponse(response)) {
        return null;
      }

      parsed = json.decode(response.body);
      int stationID = parsed['halteNummer'];
    } finally {
      client.close();
    }
  }

  bool _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      // something went wrong

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return false;
    }

    return true;
  }
}
