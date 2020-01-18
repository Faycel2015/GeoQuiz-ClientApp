import 'package:app/ui/shared/strings.dart';
import 'package:app/ui/start_up.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartUpView(),
    );
  }
}



