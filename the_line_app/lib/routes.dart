import 'package:The_Line_App/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'stationspage.dart';
import 'linespage.dart';
import 'startpage.dart';

class Router {
  static const String HOME_PATH = '/';
  static const String LOCATION_PATH = '/location';
  static const String STATIONS_PATH = '/stations';

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // HOME
      case HOME_PATH:
        return MaterialPageRoute(
          builder: (_) => StartPage(),
          fullscreenDialog: false,
          maintainState: true,
        );
      // LOCATION
      case LOCATION_PATH:
        Station station = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => LinesPage(
            selectedStation: station,
          ),
          fullscreenDialog: false,
          maintainState: true,
        );
      // STATIONS
      case STATIONS_PATH:
        return MaterialPageRoute(
          builder: (_) => Stations(),
          fullscreenDialog: false,
          maintainState: false,
        );
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
