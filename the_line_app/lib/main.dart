import 'package:The_Line_App/datamanager.dart';
import 'package:The_Line_App/favoritesmanager.dart';
import 'package:The_Line_App/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LocationManager.dart';
import 'TramManager.dart';
import 'messagemanager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IFavoritesManager>(
          create: (context) {
            // Now we use the simple IDs way of storing with Shared Preferences storage
            return FavoritesManager(SharedPrefDataManager());
          },
          lazy: true,
        ),
        Provider<LocationManager>(
          create: (context) {
            return LocationManager();
          },
          lazy: true,
        ),
        Provider<TramManager>(
          create: (context) {
            return TramManager();
          },
          lazy: true,
        ),
        Provider<MessageManager>(
          create: (context) {
            return MessageManager();
          },
          lazy: true,
        ),
      ],
      child: MaterialApp(
        title: 'theLine App',
        theme: getTheme(),
        //home: LinesPage(),
        onGenerateRoute: (settings) {
          return Router().generateRoute(settings);
        },
      ),
    );
  }

  ThemeData getTheme() {
    var themeData = ThemeData(
      primarySwatch: Colors.blue,
      textTheme: TextTheme(
        headline: TextStyle(
          color: Colors.white,
        ),
        subtitle: TextStyle(
          color: Colors.white60,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    );
    return themeData;
  }
}
