import 'package:The_Line_App/datamanager.dart';
import 'package:The_Line_App/favoritesmanager.dart';
import 'package:The_Line_App/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'locationmanager.dart';
import 'messagemanager.dart';
import 'trammanager.dart';

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
        Provider<ILocationManager>(
          create: (context) {
            return LocationManager();
          },
          lazy: true,
        ),
        Provider<ITramManager>(
          create: (context) {
            return TramManager();
          },
          lazy: true,
        ),
        Provider<IMessageManager>(
          create: (context) {
            return MessageManager();
          },
          lazy: true,
        ),
      ],
      child: MaterialApp(
        title: 'theLine App',
        theme: themeData1,
        onGenerateRoute: (settings) {
          return Router().generateRoute(settings);
        },
      ),
    );
  }
}

ThemeData themeData1 = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFFFEBCF),
  appBarTheme: AppBarTheme(
    color: const Color(0xFF305F72),
    brightness: Brightness.light,
    elevation: 8,
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF305F72),
    primaryVariant: const Color(0xFF305F72),
    secondary: const Color(0xFFF18C8E),
    secondaryVariant: const Color(0xFFF0B7A4),
    background: const Color(0xFFFFEBCF),
    error: Colors.red,
    surface: Colors.grey,
    onError: Colors.red,
    onBackground: Colors.black,
    onPrimary: Colors.blue,
    onSecondary: Colors.blue,
    onSurface: Colors.black,
  ),
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
