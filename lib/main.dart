import 'dart:async';

import 'package:app/src/locator.dart';
import 'package:app/src/router.dart';
import 'package:app/src/theme.dart';
import 'package:app/src/ui/homepage/homepage.dart';
import 'package:app/src/ui/shared/res/strings.dart';
import 'package:app/src/ui/shared/widgets/provider_notifier.dart';
import 'package:app/src/ui/startup/startup_page.dart';
import 'package:app/src/ui/startup/startup_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sqflite/sqflite.dart';

/// Entry point for the application. Set up the [Locator] and create the
/// widget tree.
/// 
/// It runs the app by creating the root widget of the app, the root widget if
/// [GeoQuizApp].
/// 
/// This function is automatically called by the engine, so you don't have to
/// call this function anywhere. The behavior is not defined if you call this
/// function again, as the services and providers are register here, calling
/// this function again will try to re-register the services and provider and
/// will caused an exception.
/// 
/// See also :
/// 
///  * [MaterialApp], which if the root of the application.
///  * [Locator], which if the service locator.
///   
void main() async {
  Locator.setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await deleteDatabase("database.db");
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runZoned(() async {
    runApp(GeoQuizApp());
  }, onError: (e, s) {
    print(e);
    Crashlytics.instance.recordError(e, s);
  });
} 

/// Root of the application, it builds a [MaterialApp].
/// 
/// The material app defined the application title, the theme, and the route
/// generator used to navigate between the different screens. To know more about 
/// the routing, see [Router].
/// 
/// Depending on the [StartUpProvider] state etheir the [Homepage] or the 
/// [StartUpPage] will be displayed (home of the material application).
class GeoQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: geoQuizTheme,
      onGenerateRoute: Router.generateRoute,
      home: ProviderNotifier<StartUpProvider>(
        builder: (context, startUpProvider, _) => startUpProvider.isReady
            ? HomePage()
            : StartUpPage(status: startUpProvider.status)
      ),
    );
  }
}