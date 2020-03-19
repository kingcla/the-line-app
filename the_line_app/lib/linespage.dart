import 'package:The_Line_App/routes.dart';
import 'package:flutter/material.dart';
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

class _LinesPageState extends State<LinesPage> with SingleTickerProviderStateMixin {
  Station _currentStation;
  bool _isFavourite;

  AnimationController _controller;
  bool _reverted;
  ILocationManager _locationManager;
  ITramManager _tramManager;
  IMessageManager _messageManager;
  IFavoritesManager _favoritesManager;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );
    _reverted = false;

    _currentStation = widget.selectedStation;
    _isFavourite = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _locationManager = Provider.of<ILocationManager>(context);
    _tramManager = Provider.of<ITramManager>(context);
    _messageManager = Provider.of<IMessageManager>(context);
    _favoritesManager = Provider.of<IFavoritesManager>(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        //backgroundColor: Theme.of(context).colorScheme.background,
        body: CurrentStation(
          currentStation: _currentStation,
          isFavourite: _isFavourite,
        ),
        floatingActionButton: ButtonBar(
          children: [
            FloatingActionButton(
              heroTag: 'pgStations',
              onPressed: () {
                if (_reverted) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
                setState(() {
                  _reverted = !_reverted;
                });
                // open the research page
                Navigator.of(context).pushNamed(Router.STATIONS_PATH);
              },
              tooltip: 'Search a stop',
              child: Icon(Icons.search),
            ),
            Builder(
              builder: (ctx) {
                return FloatingActionButton(
                  onPressed: () async {
                    var pr = new ProgressDialog(ctx, isDismissible: false, type: ProgressDialogType.Normal);
                    pr.update(message: 'Looking for stops around you...');
                    pr.show();

                    try {
                      // First get the current geo-location
                      var loc = await _locationManager.getLocation();
                      if (loc == null) {
                        _messageManager.showMessage(ctx,
                            'You will need to allow the app to get the location in order to find the nearest stop');

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
                      });
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
}
