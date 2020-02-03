import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'models.dart';

class LineStopHeader extends StatefulWidget {
  LineStopHeader(this.name, this.number, {this.favourite = false, Key key})
      : super(key: key);

  final String name;
  final String number;
  final bool favourite;

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
        color: Theme.of(context).primaryColor,
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
              setState(() {
                _isFavourite = !_isFavourite;
              });
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
        color: Theme.of(context).colorScheme.onBackground,
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
