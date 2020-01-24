import 'package:app/models/models.dart';
import 'package:flutter/widgets.dart';


class QuizProvider extends ChangeNotifier {

  Set<QuizTheme> _selectedThemes;
  List<QuizQuestion> _questions;
  Iterator _questionsIterator;

  Future<void> prepareGame(Set<QuizTheme> selectedThemes) async {
    _selectedThemes = selectedThemes;
    _questions = [];
    _questionsIterator = _questions.iterator;
  }

  QuizQuestion nextQuestion() {
    _questionsIterator.moveNext();
    return _questionsIterator.current;
  }
  

}