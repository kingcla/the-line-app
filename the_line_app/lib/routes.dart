import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'linespage.dart';

class Router {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // HOME
      case '/':
        return MaterialPageRoute(builder: (_) => LinesPage());
      // STATIONS
      case '/stations':
        return MaterialPageRoute(builder: (_) => Container());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
