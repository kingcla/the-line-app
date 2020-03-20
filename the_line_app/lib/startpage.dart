import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'components.dart';
import 'routes.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('deLine'),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              height: 50,
              child: OptionButton(
                icon: Icons.location_on,
                text: 'Nearby station',
                onPressed: () {
                  // open the location page
                  Navigator.of(context).pushNamed(Router.LOCATION_PATH);
                },
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
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
    );
  }
}
