import 'package:app/logic/database_verification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class StartUpView extends StatelessWidget {

  final bool error;

  StartUpView({Key key, this.error = false}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("loading...")
    );
  }
}



class StartUpErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "error"
    );
  }
}