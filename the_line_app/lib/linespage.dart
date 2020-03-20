import 'package:The_Line_App/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'locationmanager.dart';
import 'components.dart';
import 'favoritesmanager.dart';
import 'messagemanager.dart';
import 'models.dart';
import 'trammanager.dart';

class LinesPage extends StatefulWidget {
  LinesPage({Key key, this.selectedStation}) : super(key: key);
  final Station selectedStation;

  @override
  _LinesPageState createState() => _LinesPageState();
}

class _LinesPageState extends State<LinesPage> {
  Station _currentStation;
  bool _isFavourite;

  ILocationManager _locationManager;
  ITramManager _tramManager;
  IMessageManager _messageManager;
  IFavoritesManager _favoritesManager;

  double latitude = 0;
  double longitude = 0;
  double zoom = 0;

  @override
  void initState() {
    super.initState();

    _currentStation = widget.selectedStation;
    _isFavourite = false;

    SchedulerBinding.instance.addPostFrameCallback((_) => _getNearestStation(context));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize all providers
    _locationManager = Provider.of<ILocationManager>(context);
    _tramManager = Provider.of<ITramManager>(context);
    _messageManager = Provider.of<IMessageManager>(context);
    _favoritesManager = Provider.of<IFavoritesManager>(context);
  }

  void _getNearestStation(BuildContext ctx) async {
    var pr = new ProgressDialog(ctx, isDismissible: false, type: ProgressDialogType.Normal);
    pr.update(message: 'Looking for stops around you...');
    pr.show();

    try {
      // First get the current geo-location
      var loc = await _locationManager.getLocation();
      if (loc == null) {
        _messageManager.showMessage(
            ctx, 'You will need to allow the app to get the location in order to find the nearest stop');

        setState(() {
          _currentStation = null;
          _isFavourite = false;
        });

        return;
      }

      // Once we have a location we get all stops close to it
      var stations = await _tramManager.getNearestStations(
        loc.latitude,
        loc.longitude,
      );
      if (stations == null || stations.isEmpty) {
        _messageManager.showMessage(ctx, 'There are no stops near your position');

        setState(() {
          _currentStation = null;
          _isFavourite = false;
        });

        return;
      }

      // Once we know the stop we query for the upcoming lines
      bool isFavourite = false;
      var list = await _favoritesManager.getFavorites();

      if (list != null && list.any((s) => s.id == stations[0].id)) {
        isFavourite = true;
      } else {
        isFavourite = false;
      }

      // Finally refresh the state
      setState(() {
        _currentStation = stations[0];
        _isFavourite = isFavourite;

        latitude = _currentStation.location.latitude;
        longitude = _currentStation.location.longitude;
        zoom = 17.3;
      });
    } finally {
      await pr.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    var bottomMargin = MediaQuery.of(context).size.height / 4.5;

    return SafeArea(
      top: true,
      child: Scaffold(
        body: Stack(children: <Widget>[
          LocalMap(
            latitude: latitude,
            longitude: longitude,
            zoom: zoom,
            latShift: -0.0012,
          ),
          Container(
            margin: EdgeInsets.only(top: bottomMargin),
            child: CurrentStation(
              currentStation: _currentStation,
              isFavourite: _isFavourite,
              maxLines: 4,
            ),
          ),
        ]),
        floatingActionButton: Builder(
          builder: (ctx) {
            return FloatingActionButton(
              heroTag: 'hero_location',
              onPressed: () => _getNearestStation(ctx),
              child: Icon(Icons.location_on),
            );
          },
        ),
      ),
    );
  }
}
