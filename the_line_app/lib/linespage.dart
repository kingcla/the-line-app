import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'LocationManager.dart';
import 'TramManager.dart';
import 'components.dart';
import 'favoritesmanager.dart';
import 'messagemanager.dart';
import 'models.dart';

class LinesPage extends StatefulWidget {
  LinesPage({Key key, this.selectedStation}) : super(key: key);
  final Station selectedStation;

  @override
  _LinesPageState createState() => _LinesPageState();
}

class _LinesPageState extends State<LinesPage> {
  Station _currentStation;
  bool _isFavourite;

  @override
  void initState() {
    super.initState();

    _currentStation = widget.selectedStation;
    _isFavourite = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: CurrentStation(
          currentStation: _currentStation,
          isFavourite: _isFavourite,
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
                      var loc = await Provider.of<LocationManager>(context,
                              listen: false)
                          .canGetLocation();
                      if (loc == null) {
                        Provider.of<MessageManager>(context).showMessage(ctx,
                            'You will need to allow the app to get the location in order to find the nearest stop');

                        setState(() {
                          _currentStation = null;
                          _isFavourite = false;
                        });

                        return;
                      }

                      // Once we have a location we get all stops close to it
                      var stations =
                          await Provider.of<TramManager>(context, listen: false)
                              .getNearestStations(
                        loc.latitude,
                        loc.longitude,
                      );
                      if (stations == null || stations.isEmpty) {
                        Provider.of<MessageManager>(context).showMessage(
                            ctx, 'There are no stops near your position');

                        setState(() {
                          _currentStation = null;
                          _isFavourite = false;
                        });

                        return;
                      }

                      // Once we know the stop we query for the upcoming lines
                      bool isFavourite = false;
                      var list = await Provider.of<IFavoritesManager>(context,
                              listen: false)
                          .getFavorites();

                      if (list != null &&
                          list.any((s) => s.id == stations[0].id)) {
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
