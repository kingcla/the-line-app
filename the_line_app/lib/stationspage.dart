import 'package:The_Line_App/components.dart';
import 'package:flutter/rendering.dart';

import 'routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BordedContainer extends StatelessWidget {
  final Widget child;

  const BordedContainer({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(border: Border.all()),
    );
  }
}

class Stations extends StatefulWidget {
  @override
  _StationsState createState() => _StationsState();
}

class _StationsState extends State<Stations> {
  final myController = TextEditingController();
  double _expanded;
  @override
  void initState() {
    super.initState();

    _expanded = 0;
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        /*
        appBar: AppBar(
          /*
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.elliptical(18, 18)),
          ),
          */
          primary: true,
          title: Text('Stations'),
          elevation: 10,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.sort), onPressed: () {}),
          ],
        ),
        */
        backgroundColor: Theme.of(context).colorScheme.background,
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              // hide keyboard when tapping out of text input
              currentFocus.unfocus();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              buildSearchBar(context),
              AnimatedContainer(
                height: _expanded,
                duration: Duration(milliseconds: 300),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, bottom: 8, top: 5),
                        child: Text(
                          'Found (5)',
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: buildStationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white70,
        shape: BoxShape.rectangle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox.fromSize(
            size: Size.fromWidth(50),
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.black54,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          /*
                  Hero(
                    tag: 'pgStations',
                    child: SizedBox.fromSize(
                      size: Size.fromWidth(50),
                      child: Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  */
          Expanded(
            child: TextField(
              controller: myController,
              textAlign: TextAlign.start,
              enableSuggestions: false,
              enableInteractiveSelection: false,
              autofocus: true,
              maxLines: 1,
              minLines: 1,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(right: 10),
                  hintText: 'Enter a station number or name'),
              onTap: () {
                setState(() {
                  _expanded = 0;
                });
              },
              onChanged: (value) {
                print(value);
                //FocusScope.of(context).unfocus();
              },
              onSubmitted: (value) {
                print('submitted: $value');

                // clean the text box after searching
                myController.clear();

                setState(() {
                  _expanded = 400;
                });
              },
            ),
          ),
          /*
                  TODO: Enable it when supporting scan of barcode
                  
                  SizedBox.fromSize(
                    size: Size.fromWidth(50),
                    child: IconButton(
                      tooltip: 'Scan station barcode',
                      onPressed: () {},
                      icon: Icon(
                        Icons.camera,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  */
        ],
      ),
    );
  }

  Widget buildStationsList() {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 20, bottom: 8, top: 5),
            child: Text(
              'Favourites',
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.separated(
                itemBuilder: (ctx, index) {
                  double size = 50;
                  var color = Colors.blueGrey;
                  var data = '8';
                  return ListTile(
                    title: Text('GGG'),
                    subtitle: Text('#$index'),
                    trailing: SizedBox.fromSize(
                      size: Size.fromWidth(150),
                      child: buildList(
                        3,
                        25,
                        <Widget>[
                          LineNumberCard(
                            color: Colors.pink,
                            size: 40,
                            data: '122',
                            context: context,
                          ),
                          LineNumberCard(
                            color: color,
                            size: 40,
                            data: '6',
                            context: context,
                          ),
                          LineNumberCard(
                            color: color,
                            size: 40,
                            data: '0',
                            context: context,
                          ),
                          LineNumberCard(
                            color: Colors.pink,
                            size: 40,
                            data: '122',
                            context: context,
                          ),
                        ],
                      ),
                      /*
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        direction: Axis.horizontal,
                        //runSpacing: 3,
                        //spacing: 13,
                        //textDirection: TextDirection.rtl,
                        //verticalDirection: VerticalDirection.down,
                        //crossAxisAlignment: WrapCrossAlignment.center,
                        //runAlignment: WrapAlignment.center,
                        children: <Widget>[
                          LineNumberCard(
                            color: color,
                            size: 40,
                            data: data,
                            context: context,
                          ),
                          LineNumberCard(
                            color: color,
                            size: 40,
                            data: '4',
                            context: context,
                          ),
                          LineNumberCard(
                            color: Colors.green,
                            size: 40,
                            data: '99',
                            context: context,
                          ),
                          LineNumberCard(
                            color: color,
                            size: 40,
                            data: data,
                            context: context,
                          ),
                          LineNumberCard(
                            color: Colors.green,
                            size: 40,
                            data: '1',
                            context: context,
                          ),
                        ],
                      ),
                      */
                    ),
                  );
                },
                separatorBuilder: (ctx, index) {
                  return Divider(
                    color: Colors.black54,
                    endIndent: 10,
                    indent: 10,
                  );
                },
                itemCount: 15),
          ),
        ),
      ],
    );
  }

  Widget buildList(int maxLines, int minWidth, List<Widget> boxes) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        List<Widget> rows = List<Widget>();

        var totalWidth = (minWidth * boxes.length) + boxes.length;
/*
        while (totalWidth <= constraints.maxWidth) {
          minWidth++;
          totalWidth = (minWidth * boxes.length) + boxes.length;
        }
*/
        int count = 0;
        while (count < boxes.length && totalWidth > constraints.maxWidth) {
          //can't fit with smallest size, we need more rows
          count++;
          totalWidth = (minWidth * (boxes.length - count)) + (boxes.length - count);
        }
        /*
        if (count > maxLines) {
          throw Exception(
              'Cannot fit boxes with a minumum width of $minWidth on $maxLines lines. you will need at least $count lines!!');
        }
*/
        var lines = boxes.toList();
        //int maxPerLine = (lines.length / maxLines).ceil() + 1;
        int maxPerLine = boxes.length - count;
        if (lines.length > 0) {
          for (var i = 0; i < maxLines; i++) {
            var line = lines
                .take(maxPerLine)
                .map((b) => Container(
                      child: b,
                      width: minWidth.toDouble(),
                      height: minWidth.toDouble(),
                    ))
                .toList();

            rows.add(Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: line,
            ));

            lines = lines.skip(maxPerLine).toList();

            if (lines.length == 0) {
              break;
            }
          }
        }

        if (lines.length > 0) {
          throw Exception('The number of boxes will not fit the in $maxLines lines!');
        }

        var c = FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ));

        return c;
      },
    );
  }

  Widget buildStationsList3() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              /// To convert this infinite list to a list with "n" no of items,
              /// uncomment the following line:
              /// if (index > n) return null;
              return Text('TEST');
            },
            childCount: 3,

            /// Set childCount to limit no.of items
            /// childCount: 100,
          ),
        ),
        SliverPadding(padding: EdgeInsets.all(10)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: BordedContainer(
              child: Center(
                child: Text('Main content here'),
              ),
            ),
          ),
        ),
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              'https://cdn.pixabay.com/photo/2016/09/07/11/37/tropical-1651426__340.jpg',
              fit: BoxFit.fill,
            ),
          ),
          //floating: true,
          leading: null,
          //pinned: true,
          title: Text("SliverAppBar Title"),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              /// To convert this infinite list to a list with "n" no of items,
              /// uncomment the following line:
              /// if (index > n) return null;
              return LineStopHeader('TEST', '$index');
            },
            childCount: 7,

            /// Set childCount to limit no.of items
            /// childCount: 100,
          ),
        ),
      ],
    );
  }

  Widget buildStationsList2() {
    return ListView.builder(itemBuilder: (context, index) {
      return LineStopHeader('TEST', '$index');
    });
  }
}

class LineNumberCard extends StatelessWidget {
  const LineNumberCard({
    Key key,
    @required this.color,
    @required this.size,
    @required this.data,
    @required this.context,
  }) : super(key: key);

  final MaterialColor color;
  final double size;
  final String data;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: SizedBox.fromSize(
        size: Size.square(size),
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              data,
              textWidthBasis: TextWidthBasis.longestLine,
              textScaleFactor: 1.9,
              //style: Theme.of(context).textTheme.display1,
            ),
          ),
        ),
      ),
    );
  }
}
