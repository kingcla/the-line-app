import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class IMessageManager {
  void showMessage(BuildContext ctx, String s);
}

class MessageManager implements IMessageManager {
  @override
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
