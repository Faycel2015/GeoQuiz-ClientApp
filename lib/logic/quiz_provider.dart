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
    _selectedThemes = selectedThemes;
    _questions = [];
    _questionsIterator = _questions.iterator;
    print("end");
  }

  QuizQuestion nextQuestion() {
    _questionsIterator.moveNext();
    return _questionsIterator.current;
  }
  

}