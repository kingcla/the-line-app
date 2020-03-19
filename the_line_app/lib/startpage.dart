import 'dart:async';

import 'package:The_Line_App/locationmanager.dart';
import 'package:The_Line_App/stationspage.dart';
import 'package:The_Line_App/trammanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models.dart';
import 'routes.dart';

class _myFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const _myFloatingActionButtonLocation(this.bottomMargin);

  final double bottomMargin;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(
      scaffoldGeometry.scaffoldSize.width -
          scaffoldGeometry.minInsets.right -
          scaffoldGeometry.floatingActionButtonSize.width -
          kFloatingActionButtonMargin,
      bottomMargin,
    );
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  double latitude = 0;
  double longitude = 0;
  double zoom = 0;
  Station nearStation;

  Future<void> _getInitialLocation(BuildContext context) async {
    LocationManager mgr = LocationManager();
    var loc = await mgr.getLocation();

    TramManager _tramManager = TramManager();
    var stations = await _tramManager.getNearestStations(
      loc.latitude,
      loc.longitude,
    );

    nearStation = stations[0];

    setState(() {
      latitude = nearStation.location.latitude;
      longitude = nearStation.location.longitude;
      zoom = 17.3;
    });
  }

  @override
  void initState() {
    super.initState();

    nearStation = null;

    SchedulerBinding.instance.addPostFrameCallback((_) => _getInitialLocation(context));
  }

  @override
  Widget build(BuildContext context) {
    var bottomMargin = MediaQuery.of(context).size.height / 2;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.location_on),
      ),
      floatingActionButtonLocation: _myFloatingActionButtonLocation(bottomMargin),
      appBar: AppBar(
        title: Text('deLine'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          LocalMap(
            latitude: latitude,
            longitude: longitude,
            zoom: zoom,
            latShift: -0.0006,
          ),
          Container(
            height: 500,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: bottomMargin, left: 1, right: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 38.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    height: 50,
                    child: OptionButton(
                      icon: Icons.location_on,
                      text: 'Nearby station',
                      onPressed: () {
                        // open the research page
                        Navigator.of(context).pushNamed(
                          Router.LOCATION_PATH,
                          arguments: nearStation,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    height: 50,
                    child: OptionButton(
                      icon: Icons.search,
                      text: 'Lookup station',
                      onPressed: () {
                        // open the research page
                        Navigator.of(context).pushNamed(Router.STATIONS_PATH);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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
      child: BordedContainer(
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
      ),
    );
  }
}
