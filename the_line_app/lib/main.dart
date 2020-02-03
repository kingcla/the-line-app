import 'dart:async';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'TramManager.dart';
import 'LocationManager.dart';
import 'components.dart';
import 'models.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'theLine App',
      theme: getTheme(),
      home: MyHomePage(),
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
  GlobalKey<ScaffoldState> scaffoldState;

  LocationCoordinates _coo;

  LocationManager _manager = LocationManager();
  TramManager _tramManager = TramManager();

  List<Line> _lines;
  Station _currentStation;

  DateTime _dateTime;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    _lines = null;
    _currentStation = null;
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  Future<void> _updateTimer() async {
    var lines = await checkLines(_currentStation);

    setState(() {
      // Update once per minute.
      startTimer();

      _lines = lines;
    });
  }

  void startTimer() {
    _timer?.cancel();

    _dateTime = DateTime.now();

    _timer = Timer(
      Duration(minutes: 1) -
          Duration(seconds: _dateTime.second) -
          Duration(milliseconds: _dateTime.millisecond),
      _updateTimer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        key: scaffoldState,
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: (_currentStation != null)
                  ? LineStopHeader(
                      _currentStation.description,
                      _currentStation.id.toString(),
                    )
                  : LineStopHeader('??', '??'),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: FutureBuilder(
                  future: checkLines(_currentStation),
                  initialData: null,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      case ConnectionState.done:
                        if (snapshot.hasData) {
                          return buildLines(snapshot.data as List<Line>);
                        }

                        if (snapshot.hasError) {
                          showMessage(context, snapshot.error);
                          return Container();
                        }
                        break;
                      case ConnectionState.none:
                      default:
                        return Container();
                    }

                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: ButtonBar(
          children: [
            /*
            FloatingActionButton(
              onPressed: () {
                // open the research page
              },
              tooltip: 'Search a stop',
              child: Icon(Icons.search),
            ),
            */
            Builder(
              builder: (ctx) {
                return FloatingActionButton(
                  onPressed: () async {
                    var pr = new ProgressDialog(ctx,
                        isDismissible: false, type: ProgressDialogType.Normal);
                    pr.update(message: 'Looking for stops around you...');
                    pr.show();

                    try {
                      // First get the current geo-location
                      var loc = await _manager.canGetLocation();
                      if (loc == null) {
                        showMessage(ctx,
                            'You will need to allow the app to get the location in order to find the nearest stop');

                        setState(() {
                          _lines = null;
                          _currentStation = null;
                        });

                        return;
                      }

                      // Once we have a location we get all stops close to it
                      var stations = await _tramManager.getNearestStations(
                        loc.latitude,
                        loc.longitude,
                      );
                      if (stations == null || stations.isEmpty) {
                        showMessage(
                            ctx, 'There are no stops near your position');

                        setState(() {
                          _lines = null;
                          _currentStation = null;
                        });

                        return;
                      }

                      // Once we know the stop we query for the upcoming lines
                      //var lines = await checkLines(stations[0]);
                      //if (lines != null) {
                      setState(() {
                        _currentStation = stations[0];
                        //_lines = lines;
                      });

                      // success, start checking every minute
                      startTimer();
                      // }

                    } finally {
                      await pr.hide();
                    }
                  },
                  child: Icon(Icons.location_on),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Line>> checkLines(Station station) async {
    if (station == null) {
      return null;
    }
    var lines = await _tramManager.getIncomingLines(station, max: 5);
    // Sort the lines based on their coming time
    lines.sort((line1, line2) => line1.comingTime.compareTo(line2.comingTime));
    return lines;
  }

  Widget buildLines(List<Line> lines) {
    return RefreshIndicator(
      onRefresh: update,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return TramLineTile(
            lines[index].type,
            lines[index].linenumber.toString(),
            lines[index].direction,
            lines[index].destination,
            lines[index].color,
            (lines[index].comingTime / 60).floor().toString(),
          );
        },
        itemCount: lines != null ? lines.length : 0,
      ),
    );
  }

  void showMessage(BuildContext ctx, String s) {
    Scaffold.of(ctx).showSnackBar(
      SnackBar(
        content: Text(s),
      ),
    );
  }

  Future<void> update() async {
    var lines = await checkLines(_currentStation);
    setState(() {
      _lines = lines;
    });
  }
}
