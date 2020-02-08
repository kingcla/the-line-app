import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MessageManager {
  void showMessage(BuildContext ctx, String s) {
    ScaffoldState scaffold = Scaffold.of(ctx);

    if (scaffold == null) {
      print('No Scaffold in this context!');
      return;
    }

    scaffold.showSnackBar(
      SnackBar(
        content: Text(s),
      ),
    );
  }
}
