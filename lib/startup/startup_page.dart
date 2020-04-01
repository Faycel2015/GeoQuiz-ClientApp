import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class StartUpPage extends StatelessWidget {
  final bool error;

  StartUpPage({
    Key key, 
    this.error = false
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: error ? _Error() : _Loading()
    );
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Loading ..."),
    );
  }
}

class _Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Error"),
    );
  }
}