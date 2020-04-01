import 'package:app/ui/homepage/homepage.dart';
import 'package:app/ui/quiz/quiz.dart';
import 'package:app/ui/quiz/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case HomePage.routeName:
        return MaterialPageRoute(builder: (_) => HomePage());
      case QuizPage.routeName:
        QuizConfig config = routeSettings.arguments;
        return MaterialPageRoute(builder: (_) => QuizPage(quizConfig: config));
    }

    assert(false, "No route found for ${routeSettings.name}");
    return null;
  }
}