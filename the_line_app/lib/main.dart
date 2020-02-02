import 'package:flutter/material.dart';
import 'TramManager.dart';
import 'LocationManager.dart';
import 'components.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: getTheme(),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  LocationCoordinates _coo;

  LocationManager _manager = new LocationManager();
  TramManager _tramManager = TramManager();

  void _incrementCounter() async {
    _coo = await _manager.canGetLocation();

    _tramManager.getNearestStation(_coo);

    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
          child: Column(
            children: <Widget>[
              LineStopHeader(
                'Tropisc Instituut',
                '1345600',
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return TramLineTile(
                        index % 2 == 0 ? LineType.tram : LineType.bus,
                        '1',
                        'Groonplaats',
                        Colors.purple,
                      );
                    },
                    itemCount: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Search',
          child: Icon(Icons.search),
        ),
      ),
    );
  }
}
