import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

import 'models.dart';

class TramManager {
  static const String _locationURL =
      'https://www.delijn.be/rise-api-core/coordinaten/convert/';

  static const String _getStationURL =
      'https://www.delijn.be/rise-api-core/haltes/indebuurt/';

  static const String _getLinesURL =
      'https://www.delijn.be/rise-api-core/haltes/doorkomstenditmoment/';

  /// Get a list of upcoming busses and trams for a specific [station].
  ///
  /// It's possible to limit the number of results by using the [max] parameter. The default value is 10.
  Future<List<Line>> getIncomingLines(Station station, {int max = 10}) async {
    var client = http.Client();
    try {
      // Request the list of lines incoming at this moment
      var response = await client.get(
        _getLinesURL + station.id.toString() + '/' + max.toString(),
      );

      if (!_checkResponse(response)) {
        return null;
      }

      var parsed = json.decode(response.body);

      return (parsed['lijnen'] as List)
          .map((line) => Line.fromJson(line))
          .toList();
    } finally {
      client.close();
    }
  }

  /// Get a list of stops that are closest to the geographical location specified
  /// using [latitude] and [longitude] values.
  ///
  /// If the list is null there was an error while requesting to the API.
  ///
  /// If the list is empty, there are no station nearby.
  ///
  /// It's possible to specify a research [range] in meters. The default is 100 meters.
  Future<List<Station>> getNearestStations(double latitude, double longitude,
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
      response = await client.get(
        _getStationURL +
            coo.x.toStringAsFixed(0) +
            '/' +
            coo.y.toStringAsFixed(0) +
            '/' +
            range.toString(),
      );

      if (!_checkResponse(response)) {
        return null;
      }

      parsed = json.decode(response.body);

      return (parsed != null)
          ? (parsed as List)
              .map((station) => Station.fromJson(station))
              .toList()
          : null;
    } finally {
      client.close();
    }
  }

  bool _checkResponse(http.Response response) {
    if (response == null) {
      print('the response from request is null');
      return false;
    }

    if (response.statusCode != 200) {
      // something went wrong
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }

    if (response.body == null) {
      print('the response body from request is null');
      return false;
    }

    return true;
  }
}
