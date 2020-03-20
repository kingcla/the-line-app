import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'trammanager.dart';
import 'favoritesmanager.dart';
import 'messagemanager.dart';
import 'models.dart';

class LineStopHeader extends StatefulWidget {
  LineStopHeader(
    this.name,
    this.number, {
    this.favourite = false,
    this.onSetFavourite,
    key,
  }) : super(key: key);

  final String name;
  final String number;
  final bool favourite;

  final Function(String name, bool favourite) onSetFavourite;

  @override
  _LineStopHeaderState createState() => _LineStopHeaderState();
}

class _LineStopHeaderState extends State<LineStopHeader> {
  bool _isFavourite;

  @override
  void initState() {
    super.initState();

    _isFavourite = widget.favourite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      margin: EdgeInsets.all(10),
      child: Center(
        child: ListTile(
          title: Text(
            widget.name,
            style: Theme.of(context).textTheme.headline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '#${widget.number}',
            style: Theme.of(context).textTheme.subtitle,
          ),
          trailing: GestureDetector(
            onTap: () {
              print('pre - ${widget.onSetFavourite}');
              setState(() {
                _isFavourite = !_isFavourite;
              });

              if (widget.onSetFavourite != null) {
                widget.onSetFavourite(widget.number, _isFavourite);
              }
            },
            child: Icon(
              _isFavourite ? Icons.star : Icons.star_border,
              color: _isFavourite ? Colors.yellow : IconTheme.of(context).color,
              size: 35,
            ),
          ),
        ),
      ),
    );
  }
}

class TramLineTile extends StatelessWidget {
  const TramLineTile({
    this.type,
    this.number,
    this.name,
    this.direction,
    this.color,
    this.minutes,
    this.cancelled,
    this.realTime,
    Key key,
  }) : super(key: key);

  final LineType type;
  final String number;
  final String name;
  final Color color;
  final String direction;
  final String minutes;
  final bool cancelled;
  final bool realTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        title: Text(name),
        leading: Container(
          width: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Line type: Bus or Tram
              Icon(
                type == LineType.tram ? Icons.tram : Icons.directions_bus,
                color: realTime ? Colors.green[300] : Colors.black54,
              ),
              // Line number and color
              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 50,
                width: 50,
                child: Center(
                  child: Text(
                    number,
                    style: Theme.of(context).textTheme.button,
                    textScaleFactor: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        subtitle: Text('direction $direction'),
        trailing: Builder(builder: (context) {
          if (cancelled) {
            return Icon(
              Icons.warning,
              color: Colors.red,
            );
          } else {
            return Text(
              '$minutes\'',
              textScaleFactor: 2,
            );
          }
        }),
      ),
    );
  }
}

/// Build the [LineStopHeader] holding information of the passed [Station].
/// It will draw a list of [TramLineTile] showing [Line] infos. This list is refreshed every minute.
class CurrentStation extends StatefulWidget {
  const CurrentStation({
    Key key,
    @required this.currentStation,
    @required this.isFavourite,
    this.maxLines = 5,
  }) : super(key: key);

  final Station currentStation;
  final bool isFavourite;
  final int maxLines;

  @override
  _CurrentStationState createState() => _CurrentStationState();
}

class _CurrentStationState extends State<CurrentStation> {
  List<Line> _lines;
  Timer _timer;
  DateTime _dateTime;
  ITramManager _tramManager;
  IMessageManager _messageManager;
  IFavoritesManager _favoritesManager;

  @override
  void initState() {
    super.initState();

    _lines = null;
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  Future<void> _updateTimer() async {
    var lines = await checkLines(widget.currentStation);

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
      Duration(minutes: 1) - Duration(seconds: _dateTime.second) - Duration(milliseconds: _dateTime.millisecond),
      _updateTimer,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tramManager = Provider.of<ITramManager>(context);
    _messageManager = Provider.of<IMessageManager>(context);
    _favoritesManager = Provider.of<IFavoritesManager>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: (widget.currentStation != null)
              ? LineStopHeader(
                  widget.currentStation.description,
                  widget.currentStation.id.toString(),
                  favourite: widget.isFavourite,
                  onSetFavourite: (num, isFav) {
                    if (isFav) {
                      _favoritesManager.saveAsFavorite(Station(int.parse(num)));
                    } else {
                      _favoritesManager.removeAsFavorite(Station(int.parse(num)));
                    }
                  },
                )
              : Container(),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: (_lines != null)
                ? buildLines(_lines)
                : FutureBuilder(
                    future: checkLines(widget.currentStation),
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
                            _messageManager.showMessage(context, snapshot.error);
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
    );
  }

  Future<void> update() async {
    var lines = await checkLines(widget.currentStation);
    setState(() {
      _lines = lines;
    });
  }

  Future<List<Line>> checkLines(Station station) async {
    if (station == null) {
      return null;
    }

    var lines = await _tramManager.getIncomingLines(station, max: widget.maxLines);
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
            type: lines[index].type,
            number: lines[index].linenumber.toString(),
            name: lines[index].direction,
            direction: lines[index].destination,
            color: lines[index].color,
            cancelled: lines[index].isCancelled,
            realTime: lines[index].isRealTime,
            minutes: max((lines[index].comingTime / 60).floor(), 0).toString(),
          );
        },
        itemCount: lines != null ? lines.length : 0,
      ),
    );
  }
}

class LocalMap extends StatefulWidget {
  const LocalMap({
    Key key,
    @required this.latitude,
    @required this.longitude,
    this.zoom = 0,
    this.latShift = 0,
    this.lonShift = 0,
  }) : super(key: key);

  final double latitude;
  final double longitude;
  final double latShift;
  final double lonShift;
  final double zoom;

  static final CameraPosition _zero = CameraPosition(
    target: LatLng(0, 0),
    zoom: 1,
  );

  @override
  _LocalMapState createState() => _LocalMapState();
}

class _LocalMapState extends State<LocalMap> {
  Completer<GoogleMapController> _controller = Completer();

  Future<void> _goToPosition(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(
          latitude + widget.latShift,
          longitude + widget.lonShift,
        ),
        zoom: widget.zoom,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isCompleted) {
      _goToPosition(widget.latitude, widget.longitude);
    }

    return SizedBox.expand(
      child: GoogleMap(
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: false,
        tiltGesturesEnabled: false,
        zoomGesturesEnabled: false,
        markers: Set<Marker>.from(
          [
            Marker(
              markerId: MarkerId('place'),
              position: LatLng(widget.latitude, widget.longitude),
            )
          ],
        ),
        padding: EdgeInsets.all(5),
        mapType: MapType.normal,
        initialCameraPosition: LocalMap._zero,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  const OptionButton({
    Key key,
    this.icon,
    this.text,
    @required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      color: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).textTheme.headline.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(icon),
          Expanded(
            child: Center(
              child: Text(
                text,
                textScaleFactor: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
