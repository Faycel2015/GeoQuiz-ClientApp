import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
///
///
class WillPopScopeWarning extends StatelessWidget {

  WillPopScopeWarning({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _preventMissReturned(context),
      child: child,
    );
  }

  ///
  ///
  ///
  Future<bool> _preventMissReturned(context) {
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