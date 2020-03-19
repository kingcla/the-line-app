import 'dart:ui';

import 'package:The_Line_App/locationmanager.dart';

class MapCoordinates {
  double x, y;

  MapCoordinates(this.x, this.y);

  factory MapCoordinates.fromJson(Map<String, dynamic> data) {
    return MapCoordinates(data['xCoordinaat'], data['yCoordinaat']);
  }
}

class Station {
  num id;
  String description;
  String problems; // in case of strike or other disturbance
  List<String> destinations;
  List<Line> lines;
  List<TimeTable> timetables;
  LocationCoordinates location;

  Station(
    this.id, {
    this.description,
    this.problems,
    this.destinations,
    this.lines,
    this.timetables,
    this.location,
  });

  factory Station.fromJson(Map<String, dynamic> data) {
    return Station(
      data['halteNummer'], //number of the stop
      description: data['omschrijvingLang'],
      destinations: (data['bestemmingen'] != null) ? List.from(data['bestemmingen']) : null,
      lines: (data['lijnen'] != null) ? (data['lijnen'] as List).map((line) => Line.fromJson(line)).toList() : null,
      location: (data['coordinaat'] != null)
          ? LocationCoordinates(
              (data['coordinaat'] as Map<String, dynamic>)['lt'], ((data['coordinaat'] as Map<String, dynamic>)['ln']))
          : null,
    );
  }
}

enum LineType {
  undefined,
  tram,
  bus,
}

/// Extension class to convert String literals to Colors and viceversa.
///
/// Found on StackOverflow (https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter)
class HexColor {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class Line {
  /*
  "bestemming": "Rumst",
  "eindHalteBijSchrapping": null,
  "entiteitNummer": 1,
  "gemeentes": null,
  "halteVolgorde": 3,
  "haltes": null,
  "id": 0,
  "internLijnnummer": "1181",
  "kleurAchterGrond": "#FFCC11",
  "kleurAchterGrondRand": "#FFCC11",
  "kleurVoorGrond": "#000000",
  "kleurVoorGrondRand": "#FFFFFF",
  "lijnGeldigVan": null,
  "lijnNummer": 181,
  "lijnNummerPubliek": "181",
  "lijnRichting": "Groenplaats - Aartselaar - Rumst",
  "lijnType": "bus",
  "lijnTypeLink": "BUSLIJN",
  "lijnUrl": "1/181/7/181_Groenplaats_-_Aartselaar_-_Rumst",
  "omschrijving": "Groenplaats - Aartselaar - Rumst",
  "omschrijvingHighlighted": null,
  "predictionDeleted": false,
  "predictionShortened": false,
  "predictionStatussen": [
      "REALTIME"
  ],
  "richtingCode": 7,
  "richtingCodeAndereRichting": 6,
  "ritNummer": 173774200,
  "ritOrder": 0,
  "vertrekCalendar": 1580668999000,
  "vertrekRealtimeTijdstip": 1580668999000,
  "vertrekTheoretischeTijdstip": 1580668980000,
  "vertrekTijd": "2'",
  "viaBestemming": "",
  "voertuigNummer": "111830"
  */
  String destination;
  String direction;
  num linenumber;
  Color color;
  bool isRealTime;
  LineType type;
  int comingTime;

  Line(this.linenumber, this.destination, this.color, this.type, {this.isRealTime, this.direction, this.comingTime});

  factory Line.fromJson(Map<String, dynamic> data) {
    var realTime =
        (data.containsKey('predictionStatussen')) ? (data['predictionStatussen'] as List).contains('REALTIME') : false;

    var seconds = ((data.containsKey('vertrekCalendar') || data.containsKey('vertrekRealtimeTijdstip')) &&
            (data['vertrekCalendar'] != null || data['vertrekRealtimeTijdstip'] != null))
        ? (realTime)
            ? DateTime.fromMillisecondsSinceEpoch(data['vertrekRealtimeTijdstip']).difference(DateTime.now()).inSeconds
            : DateTime.fromMillisecondsSinceEpoch(data['vertrekCalendar']).difference(DateTime.now()).inSeconds
        : -1;

    var type = LineType.undefined;
    if (data['lijnType'] != null) {
      switch (data['lijnType'] as String) {
        case 'bus':
          type = LineType.bus;
          break;
        case 'tram':
          type = LineType.tram;
          break;
        default:
          type = LineType.undefined;
      }
    }

    return Line(
      data['lijnNummer'],
      data['bestemming'],
      (data['kleurAchterGrond'] != null) ? HexColor.fromHex(data['kleurAchterGrond']) : Color(0),
      type,
      isRealTime: realTime,
      direction: data['lijnRichting'],
      comingTime: seconds,
    );
  }
}

class TimeTable {
  Line line;
  DateTime coming;
}
