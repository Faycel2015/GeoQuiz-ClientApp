import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WillPopScopeWarning extends StatelessWidget {
  final Widget child;

  WillPopScopeWarning({
    Key key,
    @required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => preventMissReturned(context),
      child: child,
    );
  }

   ///
  ///
  ///
  Future<bool> preventMissReturned(context) {
    var completer = Completer<bool>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Are you sure",
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("NO"), 
            onPressed: () {
              Navigator.pop(context);
              completer.complete(false);
            }
          ),
          FlatButton(
            child: Text("YES"),
            onPressed: () {
              Navigator.pop(context);
              completer.complete(true);
            }
          )
        ],
      )
    );
    return completer.future;
  }
}