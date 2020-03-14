import 'package:app/models/models.dart';
import 'package:flutter/foundation.dart';

class QuizThemeProgression {
  QuizTheme theme;
  int percentage;

  QuizThemeProgression({
    @required this.theme, 
    @required this.percentage
  });
}