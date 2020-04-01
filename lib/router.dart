import 'package:app/ui/pages/home/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case HomePage.routeName:
        return MaterialPageRoute(builder: (_) => HomePage());
    }

    assert(false, "No route found for ${routeSettings.name}");
    return null;
  }
}