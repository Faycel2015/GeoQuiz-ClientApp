import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:flutter/widgets.dart';


class QuizProvider extends ChangeNotifier {

  final LocalDatabaseRepository _localRepo;

  Set<QuizTheme> _themes;
  List<QuizQuestion> _questions;
  Iterator _questionsIterator;
  
  QuizQuestion get currentQuestion => _questionsIterator?.current;
  

  QuizProvider({LocalDatabaseRepository localRepo}) : _localRepo = localRepo;
  

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> prepareGame(Set<QuizTheme> selectedThemes) async {
    _questions = null;
    _questionsIterator = null;
    _themes = selectedThemes;

    try {
      _questions = await _localRepo.getQuestions(count: 10, themes: selectedThemes);
    } catch (e) {
      print(e);
    }

    if (_questions == null || _questions.isEmpty)
      return Future.error(null);
    _questionsIterator = _questions.iterator;
    _questionsIterator.moveNext();
  }


  nextRound() {
    print("next round");
    _questionsIterator.moveNext();
    notifyListeners();
  }
}