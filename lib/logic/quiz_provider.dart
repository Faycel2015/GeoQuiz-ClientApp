import 'package:app/models/models.dart';
import 'package:flutter/widgets.dart';


class QuizProvider extends ChangeNotifier {

  Set<QuizTheme> _selectedThemes = {};
  Iterable<QuizTheme> get selectedThemes => _selectedThemes;

  
  addSelectedTheme(QuizTheme theme) {
    this._selectedThemes.add(theme);
    notifyListeners();
  }

  removeSelectedTheme(QuizTheme theme) {
    this._selectedThemes.remove(theme);
    notifyListeners();
  }

}