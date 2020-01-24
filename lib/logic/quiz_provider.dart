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
    try {
      _selectedThemes = selectedThemes;
      _questions = await _localRepo.getQuestions(count: 10, themes: _selectedThemes);
      if (_questions == null || _questions.isEmpty)
        throw Exception();
      _questionsIterator = _questions.iterator;
    } catch (e) {
      print(e);
      return Future.error(null);
    }

  }

  QuizQuestion nextQuestion() {
    _questionsIterator.moveNext();
    return _questionsIterator.current;
  }
  

}