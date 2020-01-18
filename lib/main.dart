import 'package:app/logic/database_verification_provider.dart';
import 'package:app/ui/shared/strings.dart';
import 'package:app/ui/start_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseVerificationProvider>(create: (context) => DatabaseVerificationProvider())
      ],
      child: MyApp()
    )
  );
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



