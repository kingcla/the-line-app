import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  const TramLineTile(
    this.type,
    this.number,
    this.name,
    this.direction,
    this.color,
    this.minutes, {
    Key key,
  }) : super(key: key);

  final LineType type;
  final String number;
  final String name;
  final Color color;
  final String direction;
  final String minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryVariant,
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
              Icon(
                type == LineType.tram ? Icons.tram : Icons.directions_bus,
                color: Colors.black54,
              ),
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
        trailing: Text(
          '$minutes\'',
          textScaleFactor: 2,
        ),
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
  }) : super(key: key);

  final Station currentStation;
  final bool isFavourite;

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
}
