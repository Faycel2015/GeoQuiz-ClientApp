import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class AppMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.local_drink), 
            title: Text("Buy me a coffee"), 
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.delete_forever), 
            title: Text("Reset my data"), 
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.bug_report), 
            title: Text("Report a bug"), 
            onTap: () {},
          ),
        ],
      );
  }
}