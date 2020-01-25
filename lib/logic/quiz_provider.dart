import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:flutter/widgets.dart';


class QuizProvider extends ChangeNotifier {

  final LocalDatabaseRepository _localRepo;

  Set<QuizTheme> _selectedThemes;
  List<QuizQuestion> _questions;
  Iterator _questionsIterator;

  QuizProvider({LocalDatabaseRepository localRepo}) : _localRepo = localRepo;


  Future<void> prepareGame(Set<QuizTheme> selectedThemes) async {
    _questions = null;
    _questionsIterator = null;
    _selectedThemes = selectedThemes;

    try {
      _questions = await _localRepo.getQuestions(count: 10, themes: selectedThemes);
    } catch (e) {
      print(e);
    }

    if (_questions == null || _questions.isEmpty)
      return Future.error(null);
    _questionsIterator = _questions.iterator;
  }

  QuizQuestion nextQuestion() {
    _questionsIterator.moveNext();
    return _questionsIterator.current;
  }
  

}